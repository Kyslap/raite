# Data Consumption Guide (Frontend-Backend Contract)

This document is intended for backend dev to understand how the Smart Learning Platform Hub's frontend (Flutter) consumes data, manages state, and expects data from APIs.

## 1. High-Level Data Flow

Our Flutter application uses a **Feature-First Layered Architecture** powered by **Riverpod** for state management and **Dio** for network requests. 

The data flows in a single, predictable direction:
`Backend API ➔ Dio Client ➔ Data Repository ➔ Riverpod Provider (Notifier) ➔ UI (Widget)`

## 2. Where Does the Data Enter the App?

All backend API connections should be implemented in the **Data Layer** of their respective features. 

**Path:** `lib/features/[feature_name]/data/`

- **Repositories (`*_repository.dart`)**: This is where you will swap out our current `Future.delayed` mocks with actual HTTP requests using the Dio client (which will be configured in `lib/core/network/`).
- **DTOs / Parsing**: Repositories are responsible for fetching raw JSON, passing it to our Freezed models, and returning strongly-typed Dart objects.

### Example: Auth Feature (`lib/features/auth/data/auth_repository.dart`)
Right now, `login` and `signUp` are mocked. When the backend is ready, the repository will look like this:
```dart
Future<UserModel> login(String email, String password) async {
  final response = await dioClient.post('/api/v1/auth/login', data: {
    'email': email,
    'password': password,
  });
  return UserModel.fromJson(response.data['user']);
}
```

## 3. How the UI Consumes the Data

Backend developers do **not** need to touch the UI code to connect data. The UI relies entirely on **Riverpod Providers** from the Presentation layer (`lib/features/[feature_name]/presentation/providers/`).

We use Riverpod's `AsyncValue` to automatically handle all API states (Loading, Data, and Error) in the UI.

### Example UI Consumption:
The UI watches the state of the provider and reacts instantly.
```dart
final authState = ref.watch(authStateProvider); // authState is AsyncValue<UserModel?>

// The UI responds based on what the repository returned:
isLoading: authState.isLoading, // Shows a loading spinner automatically

// We use ref.listen to trigger navigation or show snackbars on API success/error:
ref.listen(authStateProvider, (previous, next) {
  if (next is AsyncData && next.value != null) {
    context.go('/home'); // Success!
  } else if (next is AsyncError) {
    showError(next.error); // Failed!
  }
});
```

## 4. Data Models and JSON Serialization

We use `freezed` and `json_serializable` for robust data modeling. 

**Path:** `lib/features/[feature_name]/domain/`

- When designing backend JSON responses, know that our models are strictly typed and immutable.
- We generate `.fromJson()` and `.toJson()` automatically.
- Ensure that backend JSON keys exactly match our Dart variable names (or let us know so we can add `@JsonKey(name: 'backend_key')` annotations).

### Example: `UserModel`
```dart
@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    required String name,
    // Add additional properties like 'avatarUrl', 'role', etc. here
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
}
```

## Summary for Backend Developers

1. **Build the API** according to the necessary feature requirements.
2. **Define the JSON Contract** with the frontend team so the Freezed domain models can be updated to match perfectly.
3. **Plug into the Repository**: Navigate to `lib/features/[feature]/data/[feature]_repository.dart` and swap the mock functions with real Dio HTTP requests. The UI will automatically handle the loading, error, and success states!
