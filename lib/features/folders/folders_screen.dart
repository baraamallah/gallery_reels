import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import '../../core/theme.dart';
import '../../core/database.dart';
import '../swipe/swipe_provider.dart';
import './folders_provider.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/providers/nav_provider.dart';

class FoldersScreen extends ConsumerStatefulWidget {
  const FoldersScreen({super.key});

  @override
  ConsumerState<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends ConsumerState<FoldersScreen> {
  String? _selectedTagId;
  List<Map<String, dynamic>> _tags = [];

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    final db = await DatabaseService.instance.database;
    final tags = await db.query('tags');
    setState(() {
      _tags = tags;
      // We don't auto-select a tag anymore to allow album view by default
    });
  }

  @override
  Widget build(BuildContext context) {
    final albumsAsync = ref.watch(albumsProvider);
    final selectedAlbum = ref.watch(selectedAlbumProvider);

    // Grid data source
    AsyncValue<List<AssetEntity>> photoSource;
    if (_selectedTagId != null) {
      photoSource = ref.watch(taggedPhotosProvider(_selectedTagId!));
    } else {
      photoSource = ref.watch(photoListProvider);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Library',
                    style: AppTheme.headingStyle.copyWith(fontSize: 32),
                  ),
                  if (selectedAlbum != null || _selectedTagId != null)
                    TextButton.icon(
                      onPressed: () {
                        ref.read(selectedAlbumProvider.notifier).setAlbum(null);
                        setState(() => _selectedTagId = null);
                      },
                      icon: const Icon(Icons.close, size: 16, color: AppTheme.accentColor),
                      label: const Text('Clear Filters', style: TextStyle(color: AppTheme.accentColor)),
                    ).animate().fadeIn(),
                ],
              ),
            ),

            // Albums List Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text('Device Albums', style: AppTheme.bodyStyle.copyWith(color: Colors.white70, fontSize: 14)),
            ),

            // Albums List
            SizedBox(
              height: 180,
              child: albumsAsync.when(
                data: (albums) => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: albums.length,
                  itemBuilder: (context, index) {
                    final album = albums[index];
                    final isSelected = selectedAlbum?.id == album.id;
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedTagId = null); // Clear tag selection when picking album
                        ref.read(selectedAlbumProvider.notifier).setAlbum(album);
                      },
                      child: Container(
                        width: 140,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: AnimatedContainer(
                                duration: 300.ms,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected ? AppTheme.accentColor : Colors.white.withValues(alpha: 0.1),
                                    width: 2,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      FutureBuilder<List<AssetEntity>>(
                                        future: album.getAssetListRange(start: 0, end: 1),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                                            return AssetEntityImage(
                                              snapshot.data![0],
                                              isOriginal: false,
                                              thumbnailSize: const ThumbnailSize(300, 300),
                                              fit: BoxFit.cover,
                                            );
                                          }
                                          return Container(color: Colors.white.withValues(alpha: 0.05));
                                        },
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 8,
                                        right: 8,
                                        child: FutureBuilder<int>(
                                          future: album.assetCountAsync,
                                          builder: (context, snapshot) => Text(
                                            '${snapshot.data ?? 0}',
                                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Text(
                                album.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isSelected ? AppTheme.accentColor : Colors.white,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.2),
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accentColor)),
                error: (e, s) => const SizedBox(),
              ),
            ),

            const SizedBox(height: 24),

            // Tag Pills Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text('Custom Labels', style: AppTheme.bodyStyle.copyWith(color: Colors.white70, fontSize: 14)),
            ),

            // Tag Pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _tags.map((tag) {
                  final isSelected = _selectedTagId == tag['id'].toString();
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: GestureDetector(
                      onTap: () {
                        ref.read(selectedAlbumProvider.notifier).setAlbum(null); // Clear album when picking tag
                        setState(() => _selectedTagId = tag['id'].toString());
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? Color(tag['color'] as int) : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: isSelected ? Colors.transparent : Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Text(
                          tag['name'] as String,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.8, 0.8));
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // Grid
            Expanded(
              child: photoSource.when(
                data: (assets) => assets.isEmpty 
                  ? _buildEmptyState()
                  : MasonryGridView.count(
                    padding: const EdgeInsets.all(16),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    itemCount: assets.length,
                    itemBuilder: (context, index) {
                      return _FolderGridItem(asset: assets[index])
                          .animate()
                          .fadeIn(delay: (index % 10 * 50).ms)
                          .scale(begin: const Offset(0.9, 0.9));
                    },
                  ),
                loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accentColor)),
                error: (e, s) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library_outlined, size: 64, color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          const Text('No photos found', style: TextStyle(color: Colors.white38)),
        ],
      ),
    );
  }
}

class _FolderGridItem extends StatelessWidget {
  final AssetEntity asset;

  const _FolderGridItem({required this.asset});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 16,
      opacity: 0.1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AssetEntityImage(
          asset,
          isOriginal: false,
          thumbnailSize: const ThumbnailSize(400, 400),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
