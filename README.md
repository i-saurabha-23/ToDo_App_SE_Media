# Task Manager - Flutter Clean Architecture

A beautifully designed task management application built with Flutter using Clean Architecture principles and a Facebook-inspired UI.

![App Screenshot](https://raw.githubusercontent.com/your-username/your-repo-name/main/screenshots/app_preview.png)

## Features

- ✅ Create, complete, and remove tasks with smooth animations
- 🎨 Modern Facebook-inspired UI with intuitive interactions
- 🔄 Swipe to mark tasks as complete or remove them
- 🗑️ Easily clear all completed tasks
- 💾 Persistent local storage using SharedPreferences
- 📱 Beautiful splash screen with fluid animations
- 🏗️ Built with Clean Architecture for maintainability and testability

## Architecture

This project follows Clean Architecture principles to separate concerns and make the codebase maintainable and testable:

```
lib/
│
├── core/             # Core functionality and utilities
│   ├── constants/    # App-wide constants and theme
│   ├── errors/       # Error handling
│   └── usecases/     # Base usecase definitions
│
├── data/             # Data layer
│   ├── datasources/  # Data sources (local/remote)
│   ├── models/       # Data models
│   └── repositories/ # Repository implementations
│
├── domain/           # Domain layer (business logic)
│   ├── entities/     # Business entities
│   ├── repositories/ # Repository interfaces
│   └── usecases/     # Business logic use cases
│
├── presentation/     # Presentation layer
│   ├── bloc/         # BLoC state management
│   ├── pages/        # Screen pages
│   └── widgets/      # Reusable UI components
│
└── main.dart         # Application entry point
```

## Technologies Used

- **Flutter**: UI framework
- **BLoC Pattern**: State management
- **Get_it**: Dependency injection
- **Dartz**: Functional programming
- **SharedPreferences**: Local data persistence
- **Equatable**: Value equality

## Installation

1. Make sure you have Flutter installed. For installation instructions, see [Flutter's official documentation](https://flutter.dev/docs/get-started/install).

2. Clone this repository:
   ```bash
   git clone https://github.com/your-username/your-repo-name.git
   ```

3. Navigate to the project directory:
   ```bash
   cd your-repo-name
   ```

4. Get dependencies:
   ```bash
   flutter pub get
   ```

5. Run the app:
   ```bash
   flutter run
   ```

## Screenshots

<table>
  <tr>
    <td><img src="https://raw.githubusercontent.com/your-username/your-repo-name/main/screenshots/splash_screen.png" width="200"/></td>
    <td><img src="https://raw.githubusercontent.com/your-username/your-repo-name/main/screenshots/empty_state.png" width="200"/></td>
    <td><img src="https://raw.githubusercontent.com/your-username/your-repo-name/main/screenshots/task_list.png" width="200"/></td>
  </tr>
  <tr>
    <td><img src="https://raw.githubusercontent.com/your-username/your-repo-name/main/screenshots/add_task.png" width="200"/></td>
    <td><img src="https://raw.githubusercontent.com/your-username/your-repo-name/main/screenshots/completed_tasks.png" width="200"/></td>
    <td><img src="https://raw.githubusercontent.com/your-username/your-repo-name/main/screenshots/clear_tasks.png" width="200"/></td>
  </tr>
</table>

## Design

The UI is inspired by Facebook's clean and intuitive design language, featuring:

- Facebook blue primary color (#1877F2)
- Card-based task display with subtle shadows
- Bottom sheet for adding tasks
- Dismissible task cards with swipe gestures
- Smooth transitions and animations

## Project Structure

### Core Layer
Contains application-wide utilities, constants, error handling, and base classes.

### Domain Layer
Houses the business logic of the application, including entities, repository interfaces and use cases.

### Data Layer
Manages data operations and external services, containing repository implementations, models and data sources.

### Presentation Layer
Handles UI components, state management, and user interactions.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- UI design inspired by Facebook
- Architecture based on Clean Architecture principles
- Flutter team for the amazing framework