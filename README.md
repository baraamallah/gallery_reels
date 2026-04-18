# Gallery Reels 📸

A modern, high-performance Flutter gallery application designed for efficient photo management with a "reels-style" experience.

## ✨ Features

- **Gesture-Based Sorting**: Swipe cards to quickly categorize or delete photos.
- **Library Management**: Organise photos by system albums and custom tags.
- **Glassmorphism UI**: Beautiful, modern interface with frosted glass effects.
- **Fast Performance**: Built using `photo_manager` for high-speed local asset loading.
- **Safe Management**: Includes a Trash system to prevent accidental deletions.

## 🛠️ Built With

- **Flutter**: UI Framework.
- **Riverpod (v3.0)**: State management.
- **SQLite**: Local data persistence for tags and folder structure.
- **Photo Manager**: Direct interaction with device gallery.
- **Flutter Animate**: Smooth transitions and UI interactions.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK
- Android Studio / VS Code
- A physical device or emulator (Gallery features require local media access)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/gallery_reels.git
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   flutter run
   ```

## 🔐 Security (Important)

This project is configured for signed release builds. **Do NOT commit** your `.jks` keystore files or `key.properties` to public repositories. These have been added to the `.gitignore`.

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
