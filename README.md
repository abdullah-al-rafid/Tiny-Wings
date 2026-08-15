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
