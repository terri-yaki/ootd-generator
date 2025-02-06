# OOTD Generator 1.0.0

## Overview

OOTD Generator is a minimal Flutter app that helps generate a random outfit from your wardrobe. The app lets you manage clothing items, persist them using Hive, and generate an outfit in a fixed order (Top, Bottom, Footwear, and Accessory). The generated outfit is displayed with animated transitions and a chain swipe effect.

## App Preview

<img src="https://github.com/user-attachments/assets/c3678ee4-558d-4c56-92ed-9b62dd1dd42d" width="300">
<img src="https://github.com/user-attachments/assets/0ea61add-effe-4c21-a9cf-57f4b72df35b" width="300">
<img src="https://github.com/user-attachments/assets/f5bd48a4-878c-43df-9c06-6794a9ecf07b" width="300">
<img src="https://github.com/user-attachments/assets/793b0c0c-4efa-4232-bdee-b4063c610bbf" width="300">
<img src="https://github.com/user-attachments/assets/a8fc53c2-cf80-4629-b799-619c40fcbe21" width="300">

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
