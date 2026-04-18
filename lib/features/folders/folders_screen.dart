import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import '../../core/theme.dart';
import '../../core/database.dart';
import '../swipe/swipe_provider.dart';
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
      if (_tags.isNotEmpty) _selectedTagId = _tags[0]['id'].toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final albumsAsync = ref.watch(albumsProvider);
    final photoListAsync = ref.watch(photoListProvider);
    final selectedAlbum = ref.watch(selectedAlbumProvider);

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
                  if (selectedAlbum != null)
                    TextButton.icon(
                      onPressed: () => ref.read(selectedAlbumProvider.notifier).setAlbum(null),
                      icon: const Icon(Icons.close, size: 16, color: AppTheme.accentColor),
                      label: const Text('Clear Filter', style: TextStyle(color: AppTheme.accentColor)),
                    ).animate().fadeIn(),
                ],
              ),
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
                        ref.read(selectedAlbumProvider.notifier).setAlbum(album);
                        ref.read(swipeIndexProvider.notifier).reset();
                        ref.read(navTabProvider.notifier).setTab(NavTab.swipe);
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
                                  boxShadow: isSelected ? [
                                    BoxShadow(color: AppTheme.accentColor.withValues(alpha: 0.3), blurRadius: 12)
                                  ] : [],
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

            const SizedBox(height: 16),

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
                      onTap: () => setState(() => _selectedTagId = tag['id'].toString()),
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
                  ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.8, 0.8));
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // Grid
            Expanded(
              child: photoListAsync.when(
                data: (assets) => MasonryGridView.count(
                  padding: const EdgeInsets.all(16),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  itemCount: assets.length > 30 ? 30 : assets.length,
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
