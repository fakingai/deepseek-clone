# DeepSeek Chat App - GitHub Copilot Instructions

This document provides guidance for using GitHub Copilot with the DeepSeek Chat application project.

## Project Overview

DeepSeek is a Flutter-based chat application that uses OpenAI's API to provide AI-powered conversations. The app follows Clean Architecture principles and is structured in layers:

- **Presentation layer**: UI components and BLoC state management
  - Pages, widgets, and BLoC components
  - Theme configurations and UI utilities
- **Domain layer**: Business entities and use cases
  - Core business logic and rules
  - Use cases that orchestrate data flow
  - Entity definitions
- **Data layer**: Data models and repositories
  - API clients and data sources
  - Repository implementations
  - Data transfer objects (DTOs)

## Project Structure

```
lib/
├── core/                  # Application-wide utilities and constants
│   ├── constants/         # App-wide constant values
│   ├── di/                # Dependency injection
│   ├── error/             # Error handling
│   ├── network/           # Network configuration
│   ├── services/          # Core services
│   ├── themes/            # Theme configurations
│   ├── usecases/          # Core use cases
│   └── utils/             # Utility functions
├── data/                  # Data layer
│   ├── datasources/       # Remote and local data sources
│   ├── models/            # Data models
│   └── repositories/      # Repository implementations
├── domain/                # Domain layer
│   ├── entities/          # Business entities
│   ├── repositories/      # Repository interfaces
│   └── usecases/          # Business use cases
├── presentation/          # Presentation layer
│   ├── bloc/              # BLoC state management
│   ├── pages/             # App screens
│   └── widgets/           # Reusable UI components
└── main.dart              # Application entry point
```

## Key Files and Components

When working with this codebase, here are the important files to consider:

- `lib/main.dart`: Application entry point
- `lib/presentation/pages/home_page.dart`: Main chat interface
- `lib/presentation/pages/chat_page.dart`: Individual chat conversation screen
- `lib/presentation/bloc/chat/chat_bloc.dart`: State management for chat functionality
- `lib/presentation/bloc/settings/settings_bloc.dart`: State management for app settings
- `lib/data/datasources/chat_remote_data_source.dart`: Handles API communication with OpenAI
- `lib/data/datasources/local_data_source.dart`: Manages local data persistence
- `lib/core/themes/theme_provider.dart`: Manages light/dark theme support
- `lib/core/di/injection_container.dart`: Dependency injection setup
- `lib/domain/usecases/get_chat_completion.dart`: Core chat functionality

## Common Tasks

### 1. Adding/Modifying Chat Features

To add or modify chat features, you'll typically need to:

1. Update message entities in `domain/entities/message.dart`
2. Modify the API interaction in `data/datasources/chat_remote_data_source.dart`
3. Update repository implementations in `data/repositories/`
4. Add or update use cases in `domain/usecases/`
5. Modify the BLoC in `presentation/bloc/chat/`
6. Update the UI in `presentation/pages/home_page.dart` or related widgets

### 2. Adding New UI Components

When adding new UI components:

1. Create a new widget file in `presentation/widgets/`
2. Make sure it supports both light and dark themes
3. Add appropriate animations using platform-specific widgets
4. Ensure responsive design for different screen sizes
5. Follow accessibility guidelines

### 3. API Configuration

When working with the OpenAI API:

1. Update the API keys in a secure way (consider using environment variables)
2. Modify the API parameters in `chat_remote_data_source.dart`
3. Update API models in `data/models/`
4. Handle rate limiting and error responses
5. Implement proper error handling for network issues

### 4. State Management with BLoC

When working with BLoC pattern:

1. Define events in `*_event.dart` files
2. Define states in `*_state.dart` files
3. Implement logic in `*_bloc.dart` files
4. Use repositories and use cases in the BLoC
5. Follow unidirectional data flow principles

### 5. Dependency Injection

When adding new dependencies:

1. Register singletons or factories in `core/di/injection_container.dart`
2. Follow the existing pattern for dependency registration
3. Consider using the get_it package for service location

## Testing

To contribute tests:

1. Add unit tests in the `test/` directory
2. Create widget tests for UI components
3. Use integration tests for end-to-end testing
4. Follow the same layered architecture for tests
5. Mock dependencies using Mockito or similar libraries
6. Structure tests with the AAA pattern (Arrange, Act, Assert)
7. Use golden tests for UI verification when appropriate

## Error Handling

1. Use the Result pattern for error handling
2. Create specific error types in `core/error/`
3. Handle network errors appropriately
4. Provide user-friendly error messages
5. Log errors for debugging purposes

## Localization

1. Use the Flutter intl package for translations
2. Keep translation files in the `l10n/` directory
3. Use the `AppLocalizations` class for accessing translations
4. Avoid hardcoded strings in the UI

## Best Practices

1. Follow Clean Architecture principles
2. Maintain separation of concerns
3. Use appropriate state management with BLoC
4. Write meaningful comments and documentation
5. Keep UI code separate from business logic
6. Use const constructors when possible for performance
7. Implement proper error handling and validation
8. Follow Flutter's performance best practices
9. Use named parameters for better readability
10. Write tests for critical functionality

When using Copilot, consider asking for specific changes to particular layers rather than end-to-end implementations to maintain the architectural integrity.
