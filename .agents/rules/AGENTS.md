# Retro Learning Platform Hub: Architecture & Engineering Guidelines

This document serves as the central source of truth for all developers and AI agents working on the "Smart Learning Platform Hub" application. It outlines the architectural patterns, technical defaults, and engineering practices to ensure consistency.

## 1. Tech Stack
- **Framework**: Flutter
- **State Management**: Riverpod (`flutter_riverpod`)
- **Routing**: GoRouter (`go_router`
- **Network**: Dio (`dio`)
- **Data Modeling**: Freezed (`freezed`, `json_serializable`)
- **Typography**: Google Fonts (`google_fonts` - Plus Jakarta Sans)

## 2. Architectural Pattern
We use a **Feature-First Layered Architecture**. Code is organized by feature rather than by technical layer.

### Directory Structure
```text
lib/
├── core/                  # App-wide shared code
│   ├── theme/             # Colors, Typography, Theme data
│   ├── routing/           # GoRouter setup
│   ├── network/           # Dio client setup
│   └── utils/             # Shared helpers, constants
├── features/              # Feature modules
│   ├── [feature_name]/
│   │   ├── presentation/  # UI Widgets, Screens, and Riverpod Notifiers (Controllers)
│   │   ├── domain/        # Entities, Freezed Models, Repository Interfaces
│   │   └── data/          # Repository Implementations, Data Sources, DTOs
└── main.dart              # App entry point
```

## 3. Engineering Practices & Rules

### State Management (Riverpod)
- **Always use `ConsumerWidget` or `ConsumerStatefulWidget`** for UI components that depend on state.
- **Prefer `AsyncValue`** for handling loading, error, and data states during asynchronous operations.
- Keep business logic inside Riverpod `Notifier` or `AsyncNotifier` classes, **never** inside the UI layer.

### Immutability
- **All data models must be immutable.** Use `freezed` to generate models.
- Avoid passing complex, mutable objects around. Use `copyWith` to mutate state.

### UI & Design System (Retro Theme)
- **Colors**: Never hardcode colors in widgets. Always use the central theme (`Theme.of(context).colorScheme`).
  - Primary (Focus): `#375742` with container `#4F7059`
  - Secondary/Surface: Warm Beige (`#685D45` / `#F0E1C2`)
  - Background: Cream (`#FCF9F2`)
- **Typography**: Use `Plus Jakarta Sans` defined in the text theme.
- **Elevation**: Avoid 1px solid borders. Use soft, green-tinted ambient shadows for depth (e.g. `primaryContainer` with 0.08 opacity).
- **Shapes**: Standard UI elements use `8px` (`0.5rem`) border radius, with `24px` (pill-shaped) for primary action buttons.
- **Widgets**: Extract repetitive UI elements (Buttons, Inputs, Cards) into reusable components in `lib/core/theme/widgets/`.

### Code Style
- **Formatting**: Always use trailing commas for Flutter widgets to ensure consistent and readable formatting.
- **Imports**: Use relative imports for files within the same feature, and absolute `package:` imports for cross-feature or core dependencies.

## 4. Agent Instructions
- **Context**: When generating code for UI, always reference the Retro Design System defined in this document.
- **Dependencies**: Do not introduce new state management or routing libraries. Stick to Riverpod and GoRouter.
- **Generation**: Place generated models into their respective `domain/` folders and ensure you run `build_runner` for Freezed.
