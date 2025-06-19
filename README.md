# AVD Assets

AVD Assets is a Flutter application designed for managing and tracking assets within an organization. The app provides features for user authentication, asset/product management, filtering, and detailed product views, with support for multiple user roles and departments.

## Features

- **User Authentication:** Secure login with mobile number and password.
- **Role-Based Access:** Supports different user roles (Admin, Kitchen, Video, Decoration departments) with filtered access to products.
- **Product Management:** 
  - View a list of products/assets.
  - Add new products with details such as name, description, category, organization, department, and location.
  - Edit and delete existing products.
- **Filtering & Search:**
  - Filter products by category, department, and location.
  - Search products by name.
- **Product Details:** View detailed information about each product, including images, description, and storage details.
- **Modern UI:** Clean, animated, and responsive user interface with support for light and dark themes.
- **Persistent State:** Uses `shared_preferences` and `get_storage` for storing user session and filter preferences.
- **Media Support:** Handles image and video assets for products.

## Screenshots

*(Add screenshots of the login page, product list, product details, and filter page here)*

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Dart SDK (compatible with Flutter)
- Android Studio or Xcode for mobile development

### Installation

1. **Clone the repository:**
   ```bash
   git clone <your-repo-url>
   cd avd_assets
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

### Configuration

- The app uses a backend API for authentication and product management. Update the API URLs in the controllers if your backend endpoints differ.
- Asset images and videos should be placed in the `assets/` directory. The `pubspec.yaml` is already configured to include these assets.

## Project Structure

```
lib/
  controller/         # Business logic and state management (GetX)
  model/              # Data models (Product, Category, Department, etc.)
  Screens/            # UI screens (Home, Add/Edit Product, Filters, etc.)
  widgets/            # Reusable UI components
assets/               # Images and videos used in the app
```

## Dependencies

Key packages used:

- [`get`](https://pub.dev/packages/get): State management and navigation
- [`shared_preferences`](https://pub.dev/packages/shared_preferences): Persistent storage
- [`get_storage`](https://pub.dev/packages/get_storage): Lightweight key-value storage
- [`http`](https://pub.dev/packages/http): HTTP requests
- [`image_picker`](https://pub.dev/packages/image_picker): Image selection
- [`video_player`](https://pub.dev/packages/video_player): Video playback
- [`shimmer`](https://pub.dev/packages/shimmer): Loading animations
- [`carousel_slider`](https://pub.dev/packages/carousel_slider): Image carousels
- [`liquid_pull_to_refresh`](https://pub.dev/packages/liquid_pull_to_refresh): Pull-to-refresh UI
- And more (see `pubspec.yaml` for the full list)

## Customization

- **Themes:** Easily switch between light and dark themes.
- **Departments & Categories:** Add or modify departments, categories, and locations via the backend or by extending the models/controllers.

## Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

## License

*(Specify your license here, e.g., MIT, Apache 2.0, etc.)*
