# OOTD Generator

## Overview

OOTD Generator is a minimal Flutter app that helps you generate a random outfit from your wardrobe items. The app allows you to manage clothing items, persist them using Hive, and generate an outfit with swipe effect. Outfits are generated in a fixed order: Top, Bottom, Footwear, and Accessory.

## Features

- **Wardrobe Management**
  - Add new clothing items with a photo, name, tags, and category.
  - Edit and delete existing clothing items with confirmation.
  - Persistent storage via Hive (data is saved across app restarts).

- **Outfit Generation**
  - Generates a random outfit in fixed order: Top, Bottom, Footwear, and Accessory.
  - Displays the outfit with a staggered item tree.
  - Each outfit item is clickable—tapping an item shows its details in a popup.

- **Swipe Actions**
  - Swipe to dismiss the current outfit.
  - Dragging one item moves the others.
  - Snackbar notifications on dismissal.

- **Platform Support**
  - Runs on Android, iOS and Desktop.
  - Desktop window size configurable (using the `window_size` package, check main.dart).

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
## License

This project is provided for **non-commercial use only**. You may modify and distribute it for personal or academic purposes. Commercial use by others is prohibited.

See the LICENSE file for details.

## Notes

- The app uses Hive for local data persistence.
- The code is minimal and straightforward.
