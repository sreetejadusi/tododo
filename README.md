# TodoDo

TodoDo is a Flutter ToDo application built with a clean, layered architecture and offline-first local persistence.

It supports task creation/editing, smart list interactions, local reminder notifications, and modern Material 3 UI patterns.

## Features

- Create and edit tasks from a bottom sheet composer
- Task fields:
  - Title
  - Description
  - Optional priority (`Low`, `Medium`, `High`, or `None`)
  - Due date and due time
  - Reminder lead time (`5`, `10`, `15`, `30` minutes before)
- Task list interactions:
  - Swipe right to delete
  - Swipe left to toggle complete/incomplete
  - Drag-and-drop reordering with hamburger drag handle
  - Real-time search by title/keyword
  - Sorting by priority, due date, and creation date
- Completion UX:
  - Completed tasks are visually muted
  - Active tasks remain visually prominent
- Local persistence with Hive
- Scheduled local notifications for due reminders
- Reminder re-sync on app startup to recover schedules after app restart

## Architecture

The app follows a layered structure with BLoC state management and dependency injection:

- `core/`
  - App-level services (Hive initialization, notifications, service locator)
- `data/`
  - Models and repository implementations
- `presentation/`
  - `bloc/` for state/events
  - `view/` for screens/sheets
  - `widgets/` for reusable UI components
  - `viewmodel/` kept as structural placeholder for MVVM compatibility

### State Management

- `flutter_bloc` is used for presentation state orchestration
- `TaskBloc` handles:
  - `LoadTasks`
  - `AddTask`
  - `UpdateTask`
  - `DeleteTask`
  - `SortTasks`
  - `SearchTasks`
  - `ReorderTasks`

All business/data side effects are in BLoC/services, not in UI widgets.

### Dependency Injection

- `get_it` is used as a service locator
- Services and blocs are registered in `lib/core/services/service_locator.dart`

## Local Notifications

Notifications are encapsulated in:

- `lib/core/services/notification_service.dart`

Behavior:

- Schedules reminders based on each task’s due date/time and selected reminder lead time
- Cancels/reschedules reminders when tasks are deleted/updated
- Syncs reminders for all stored tasks on app startup

### Important platform note

Local notifications generally work when the app is inactive/terminated. However, exact delivery can still be affected by OS/user-level constraints (disabled notification permission, battery restrictions, force-stop behavior on Android).

## Tech Stack

- Flutter (Material 3)
- Hive (`hive`, `hive_flutter`) for local database
- BLoC (`flutter_bloc`, `equatable`) for state management
- DI (`get_it`)
- Notifications (`flutter_local_notifications`, `timezone`, `flutter_timezone`)

## Project Structure

```text
lib/
  core/
    services/
      hive_service.dart
      notification_service.dart
      service_locator.dart
  data/
    models/
      task_model.dart
      task_hive_adapter.dart
    repositories/
      task_repository.dart
  presentation/
    bloc/
      task_bloc.dart
      task_event.dart
      task_state.dart
    view/
      task_list_screen.dart
      create_edit_task_screen.dart
    widgets/
      task_list_item.dart
    viewmodel/
      task_viewmodel.dart
  main.dart
```

## Getting Started

### Prerequisites

- Flutter SDK (stable)
- Android Studio / Xcode toolchains configured
- A connected device or emulator/simulator

### Install dependencies

```bash
flutter pub get
```

### Run the app

```bash
flutter run
```

### Build debug APK

```bash
flutter build apk --debug
```

## Android Notification Requirements

The project already includes required Android permissions/receivers in `AndroidManifest.xml`, including:

- `POST_NOTIFICATIONS`
- `RECEIVE_BOOT_COMPLETED`
- `SCHEDULE_EXACT_ALARM`

## iOS Notification Requirements

The project includes notification usage description in `Info.plist`.

At runtime, users must grant notification permission for reminders to appear.

## Quality Checks

Run static analysis:

```bash
flutter analyze
```

## License

This project is distributed under the license in [LICENSE](LICENSE).
