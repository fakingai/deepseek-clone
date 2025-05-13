# DeepSeek Chat App

DeepSeek is a mobile application that provides AI-powered chat functionality similar to ChatGPT. It's built with Flutter and follows Clean Architecture principles.

## Project Architecture

This project is organized following Clean Architecture principles, which separates the code into layers:

### Layers

1. **Presentation Layer**
   - UI components, screens and widgets
   - State management using BLoC pattern
   - Located in `lib/presentation/`

2. **Domain Layer**
   - Business entities and use cases
   - Repository interfaces
   - Located in `lib/domain/`

3. **Data Layer**
   - Repository implementations
   - Data sources (API clients)
   - Data models
   - Located in `lib/data/`

4. **Core**
   - Shared utilities, constants, and services
   - Located in `lib/core/`

## Features

- Chat interface with AI assistant
- Dark/Light theme support
- File and image upload
- Web search integration
- Deep thinking mode for complex queries

## Setup and Installation

### Prerequisites

- Flutter SDK (latest stable version)
- Android Studio or Visual Studio Code
- Android SDK for Android development
- Xcode for iOS development (macOS only)
- OpenAI API key

### Environment Setup

1. Clone the repository:
   ```
   git clone https://github.com/fakingai/deepseek-clone.git
   cd deepseek-clone
   ```

2. Install dependencies:
   ```
   flutter pub get
   ```

3. Configure your OpenAI API key:
   - Edit `lib/data/datasources/chat_remote_data_source.dart`
   - Replace 'YOUR_OPENAI_API_KEY' with your actual API key
   
   Note: In a production app, you should use a secure method to store your API key.

## Running the App

### Debug Mode

To run the app in debug mode:

```
flutter run
```

### Building for Release

#### Android

Build an APK:
```
flutter build apk
```

Build an Android App Bundle:
```
flutter build appbundle
```

#### iOS (macOS only)

Build for iOS:
```
flutter build ios
```

Note: For iOS, you'll need to use Xcode to create an archive and distribute the app.

## Testing

Run tests:
```
flutter test
```

## Project Structure

```
lib/
├── core/                    # Core functionality and utilities
│   ├── constants/           # App constants
│   ├── di/                  # Dependency injection
│   ├── network/             # Network related code
│   └── themes/              # Theme configuration
├── data/                    # Data layer
│   ├── datasources/         # Remote and local data sources
│   ├── models/              # Data models
│   └── repositories/        # Repository implementations
├── domain/                  # Domain layer
│   ├── entities/            # Business entities
│   ├── repositories/        # Repository interfaces
│   └── usecases/            # Business logic use cases
├── presentation/            # Presentation layer
│   ├── bloc/                # State management
│   ├── pages/               # UI screens
│   └── widgets/             # Reusable UI components
└── main.dart                # App entry point
```

## Contributing

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin feature/my-new-feature`
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
