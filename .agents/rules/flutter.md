---
description: Strict Flutter MVVM Rules
globs: "**/*.dart"
alwaysOn: true
---
# Strict Flutter MVVM Rules

- **Arch**: `lib/features/[feature]/{models,viewmodels,views}` & `lib/core/`.
- **View**: UI rendering ONLY. NEVER include business logic or raw data mapping.
- **ViewModel**: State/business logic ONLY. NEVER import `flutter/material.dart` or use `BuildContext`/`Widget` refs.
- **Model**: Pure Dart entities ONLY. No UI dependencies.
- **Naming**: `UpperCamelCase` (classes/enums), `lowerCamelCase` (vars/funcs), `snake_case` (files/dirs). Suffix classes with `ViewModel` & `View`/`Page`.
- **Types**: ALWAYS use explicit public types. NEVER use force unwrap (`!`). Safely handle nulls with `?`, `??`, `??=`.
- **UI**: Maximize `const`. Refactor large `build()`/`_buildX()` into standalone `StatelessWidget`. ALWAYS use `ListView.builder` (NEVER raw `ListView`). ALWAYS use `LayoutBuilder`/`Flexible` (NEVER hardcoded dimensions).
- **State**: Explicitly handle async states (`Initial`, `Loading`, `Success`, `Error`). NEVER use broad `setState()`. ALWAYS dispose ALL controllers/listeners in `dispose()`.
- **Errors/Logs**: ALWAYS use `log()` from `dart:developer`. NEVER use `print()`. Catch specific exceptions.
- **Output**: Generate FULL, compilable files ONLY. NEVER use placeholders or truncation comments.
