# 🪽 TinyWings

> A centralized childcare support and philanthropic ecosystem built with Flutter and Firebase.

TinyWings is a role-based mobile application designed to connect childcare organizations, volunteers, donors, sponsors, and administrators through a centralized digital platform.

The platform provides a unified environment for managing organizations, support needs, donations, sponsorships, volunteering opportunities, notifications, and user profiles.

---

## ✨ Key Features

### 🔐 Authentication & User Management

- Firebase Authentication
- Email and password authentication
- User registration and login
- Role-based user management
- Profile management
- Password management
- Persistent authentication state

### 👥 User Roles

TinyWings supports multiple user roles:

- 👤 User
- 🤝 Volunteer
- 🛡️ Admin

Each role provides access to different features and functionality.

### 🏠 Dashboard

- Personalized home dashboard
- Quick access to major features
- Featured organizations
- Active support needs
- Donation and sponsorship opportunities
- Volunteer opportunities
- Notifications

### 🏢 Organizations

- Browse childcare organizations
- View organization details
- Organization profiles
- Organization-related needs
- Organization support information

### 🆘 Needs & Support

- Browse active support needs
- View detailed requirements
- Track target and fulfilled quantities
- Priority-based needs
- Deadline information
- Support and donation workflow

### 💝 Donations

- Browse donation opportunities
- Donation workflow
- Donation confirmation
- Donation history
- Transaction information

### 👶 Child Sponsorship

- Browse sponsorship opportunities
- View child profiles
- Sponsorship details
- Sponsorship checkout
- Active sponsorship management
- Sponsorship history

### 🤝 Volunteering

- Browse volunteer opportunities
- View opportunity details
- Apply for volunteering opportunities
- Manage volunteer applications
- Volunteer history
- Personal volunteering dashboard

### 🏆 Leaderboard

- Volunteer leaderboard
- Contribution-based ranking
- Community engagement tracking

### 🔔 Notifications

- Application notifications
- Donation-related notifications
- Sponsorship updates
- System notifications

### ⚙️ Settings

- Account settings
- Notification settings
- Privacy settings
- Help & support
- Theme preferences

### 🌙 Theme Support

- ☀️ Light Mode
- 🌙 Dark Mode
- Material 3 themed UI
- Consistent typography and components

---

## 🛠️ Technologies Used

### 📱 Framework

- Flutter
- Dart
- Material 3

### 🧠 State Management

- Riverpod

### 🔥 Backend & Services

- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Firebase Realtime Database

### 🎨 UI & Design

- Material Design
- Custom Material 3 theming
- Responsive layouts
- Flutter animations
- Custom reusable widgets

### 🧪 Testing & Code Quality

- Flutter Test
- Flutter Lints

---

## 🏗️ Architecture

TinyWings follows a feature-based project architecture to keep the application modular, scalable, and maintainable.

The project separates core functionality, features, data repositories, providers, services, routing, and reusable UI components.

---

## 📂 Project Structure

```text
lib/
│
├── core/
│   ├── api/
│   │   └── firebase_providers.dart
│   │
│   ├── auth/
│   │   ├── auth_repository.dart
│   │   └── project_auth_accounts.dart
│   │
│   ├── models/
│   │   └── user_model.dart
│   │
│   ├── services/
│   │   ├── db_initializer.dart
│   │   └── storage_service.dart
│   │
│   ├── theme/
│   │   └── app_theme.dart
│   │
│   └── widgets/
│
├── features/
│   │
│   ├── auth/
│   │   └── pages/
│   │
│   ├── home/
│   │   └── pages/
│   │
│   ├── organizations/
│   │   ├── data/
│   │   ├── models/
│   │   ├── pages/
│   │   └── providers/
│   │
│   ├── needs/
│   │   ├── data/
│   │   ├── models/
│   │   ├── pages/
│   │   └── providers/
│   │
│   ├── donations/
│   │   ├── data/
│   │   ├── models/
│   │   └── pages/
│   │
│   ├── sponsorships/
│   │   ├── data/
│   │   ├── models/
│   │   └── pages/
│   │
│   ├── volunteering/
│   │   ├── data/
│   │   ├── models/
│   │   └── pages/
│   │
│   ├── profile/
│   │   ├── data/
│   │   ├── models/
│   │   ├── pages/
│   │   └── providers/
│   │
│   ├── notifications/
│   │   └── pages/
│   │
│   └── settings/
│       └── pages/
│
├── routes/
│   └── app_routes.dart
│
├── firebase_options.dart
├── app.dart
└── main.dart
```
## 🔥 Firebase Integration

TinyWings uses Firebase as its backend infrastructure.

### Firebase Authentication

Firebase Authentication handles:

- User registration
- User login
- Authentication state
- Password management
- User sessions

### Cloud Firestore

Cloud Firestore is used for application data including:

- Users
- Organizations
- Needs
- Donations
- Sponsorships
- Volunteer opportunities
- Applications
- Notifications
- Other application records

### Firebase Storage

Firebase Storage is used for:

- Profile pictures
- User-uploaded images
- Application media assets

### Firebase Realtime Database

Realtime Database is used for selected real-time application data and mappings.

---

## 🚀 Getting Started

### Prerequisites

Make sure you have the following installed:

- Flutter SDK
- Dart SDK
- Android Studio or VS Code
- Android Emulator or a physical Android device
- Firebase project

### 1. Clone the Repository

```bash
git clone https://github.com/abdullah-al-rafid/Tiny-Wings.git
cd Tiny-Wings
```

### 2. Install Dependencies

    flutter pub get

### 3. Configure Firebase

Make sure your Firebase project is configured correctly.

The project uses:

- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Firebase Realtime Database

The Firebase configuration is generated through FlutterFire CLI.

    flutterfire configure

### 4. Run the Application

    flutter run

To run on Chrome:

    flutter run -d chrome

### 5. Run Tests

    flutter test

---

## 🔐 Security

TinyWings uses Firebase Authentication and Firestore Security Rules to control access to application data.

Authenticated users are required for protected Firestore operations.

For production deployment, security rules should be further restricted according to user roles and collection-level permissions.

---

## 📊 Core Data Modules

The application is organized around several major data modules:

    Users
    Organizations
    Needs
    Donations
    Sponsorships
    Children
    Volunteer Opportunities
    Applications
    Notifications
    Transactions

These modules work together to create a centralized childcare support ecosystem.

---

## 🎨 User Experience

TinyWings focuses on providing a clean and intuitive mobile experience.

The application includes:

- Material 3 components
- Responsive layouts
- Reusable UI components
- Animated interactions
- Smooth page transitions
- Interactive cards
- Form validation
- Confirmation dialogs
- Empty states
- Loading states
- Error handling
- Light and dark themes

---

## 🧪 Testing

The project supports Flutter's testing framework.

Run all tests with:

    flutter test

Static analysis can be performed with:

    flutter analyze

---

## 🔮 Future Improvements

- Advanced role-based Firestore security rules
- Push notification integration
- Advanced donation payment gateway
- Online payment verification
- Advanced volunteer statistics
- Donation analytics dashboard
- Sponsorship analytics
- Organization verification system
- Advanced search and filtering
- Cloud-based reporting
- Admin analytics dashboard
- Improved automated testing
- Performance optimization

---

## 📱 Supported Platforms

The project is configured for multiple Flutter platforms:

- Android
- iOS
- Web
- Windows
- macOS

---

## ⚠️ Disclaimer

TinyWings is developed for educational, academic, and portfolio purposes.

The application is a prototype and may require additional security, payment verification, moderation, and infrastructure improvements before being used as a production-grade philanthropic platform.

---

## 👨‍💻 Author

### Abdullah Al Rafid

**Computer Science & Engineering**  
**Daffodil International University**

- 🔗 GitHub: https://github.com/abdullah-al-rafid
- 🔗 LinkedIn: https://www.linkedin.com/in/abdullah-al-rafid-228b03247/

---

## 📄 License

This project is intended for educational and portfolio purposes.

If you choose to reuse or modify the project, please provide appropriate attribution.

---

## ⭐ Support

If you find this project interesting, consider giving the repository a ⭐ on GitHub.
