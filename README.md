# Enterprise App

An Enterprise Flutter application built with Riverpod, Ferry (GraphQL), and Hive for local storage.

## Getting Started

### Prerequisites

- Flutter SDK 3.10.3 or higher
- Dart SDK 3.10.3 or higher

### Installation

1. **Install dependencies**
   ```bash
   flutter pub get
   ```

2. **Run code generation**
   
   Run the build_runner script to generate code for both the main app and packages:
   ```bash
   ./build_runner.sh
   ```
   
   Or run manually:
   ```bash
   # In packages/api_auth
   cd packages/api_auth
   dart run build_runner build --delete-conflicting-outputs
   cd ../..
   
   # In main app
   dart run build_runner build --delete-conflicting-outputs
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Development

- **Watch mode for code generation:**
  ```bash
  dart run build_runner watch -d
  ```

- **Clean and rebuild:**
  ```bash
  flutter clean
  flutter pub get
  ./build_runner.sh
  ```

## Project Structure

- `lib/` - Main application code
- `packages/api_auth/` - Authentication API package
- Platform-specific folders: `android/`, `ios/`, `web/`, `linux/`, `macos/`, `windows/`

## Key Dependencies

- **State Management:** Riverpod
- **GraphQL Client:** Ferry
- **Local Storage:** Hive
- **Logging:** Talker
