# OOTD Generator 1.0.0.1

## Overview

OOTD Generator is a minimal Flutter app that helps generate a random outfit from your wardrobe. The app lets you manage clothing items, persist them using Hive, and generate an outfit in a fixed order (Top, Bottom, Footwear, and Accessory). The generated outfit is displayed with animated transitions and a chain swipe effect.

## Features

- **Wardrobe Management**
  - Add, edit, and delete clothing items with photo, name, tags, and category.

- **Outfit Generation**
  - Generates a random outfit in fixed order: Top, Bottom, Footwear, and Accessory.
  - Tapping an item shows its details in a popup window.

- **Swipe Actions**
  - Swipe to dismiss the current outfit.
  - Snackbar notifications on dismissal.

- **Cross-Platform**
  - Runs on Desktop, will release app on Android and iOS soon.
  - Desktop window size is configurable (using the `window_size` package).

## Installation

1. **Clone the Repository**
   ```bash
   git clone https://github.com/terri-yaki/ootd-generator
   cd ootd
2. **Instakll Dependencies**
   ```bash
   flutter pub get
3. **Generate Hive Adapters**
    ```bash
    dart run build_runner build
~~flutter pub run build_runner build~~ (deprecated)

4. **Run the app**
    ```bash
    flutter run
## Release
Download the latest release from [GitHub Releases](https://github.com/terri-yaki/ootd-generator/releases).

## License

This project is provided for **non-commercial use only**. You may modify and distribute it for personal or academic purposes. Commercial use by others is prohibited.

See the LICENSE file for details.

## Notes

- The app uses Hive for local data persistence.
- The code is minimal and straightforward.
