# AssetTrackr

AssetTrackr is a Flutter application for managing and tracking assets within an organization. The app supports user authentication, role- and department-based access, product/asset management, filtering, media support, and a responsive UI with light/dark themes.

## Features

- Secure login with mobile number and password
- Role-based access control (Admin and department roles)
- View, add, edit, and delete products/assets
- Filter and search products by category, department, and location
- Product detail pages with images and media
- Persistent session and preference storage
- Responsive, animated UI with light/dark themes

## Screenshots

Add screenshots to `assets/screenshots/` and reference them below. Example:

![Login screen](assets/screenshots/login.png)

## Getting started

### Prerequisites

- Flutter SDK (stable channel) — see https://flutter.dev/docs/get-started/install
- Android Studio or Xcode for mobile builds
- A working backend API for authentication and product management

### Installation

1. Clone the repository:

```bash
git clone https://github.com/Parth369000/AssetTrackr.git
cd AssetTrackr
```

2. Install dependencies:

```bash
flutter pub get
```

3. Run the app (debug):

```bash
flutter run
```

Build for a specific device/emulator or run from your IDE.

### Configuration

- The app expects a backend API. Update the API base URL in your project where the API client or controllers define it (search the repo for `baseUrl`, `API_URL`, or `ApiClient`).
- Place app images/screenshots in `assets/` and ensure they are listed in `pubspec.yaml`.

## Project structure

```
lib/
  controller/       # Business logic and state management (GetX or similar)
  model/            # Data models (Product, Category, Department, etc.)
  Screens/          # UI screens (Home, Add/Edit Product, Filters, etc.)
  widgets/          # Reusable UI components
assets/             # Images, videos, screenshots used in the app
```

## Dependencies

See `pubspec.yaml` for the full list. Key packages used include `get`, `shared_preferences`, `get_storage`, `http`, `image_picker`, and `video_player`.

## Development

- Use `flutter analyze` to run static analysis.
- Use `flutter format .` to format code.
- Run unit/widget tests with `flutter test` if tests are present.

## Contributing

Contributions are welcome. To contribute:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit your changes and push the branch
4. Open a pull request describing your changes

## License

This repository does not include a license file. Add a `LICENSE` if you intend to open-source under a specific license.
