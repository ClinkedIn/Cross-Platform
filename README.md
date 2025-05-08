Locked<img alt="LockedIn Logo" src="https://upload.wikimedia.org/wikipedia/commons/c/ca/LinkedIn_logo_initials.png" width=20 height=20> - Professional Networking Platform



LockedIn is a cross-platform professional networking application built with Flutter that enables users to connect, share professional experiences, and discover job opportunities. The platform offers a comprehensive suite of features for career development and professional networking.

✨ Features
👤 User Profiles
Comprehensive Profiles: Create and customize detailed professional profiles
Experience & Education: Showcase your work history and educational background
Skills Showcase: Highlight your technical and professional skills
Profile Privacy Settings: Control who can view your profile information
🔗 Networking
Connection Management: Send, accept, or reject connection requests
Network Visualization: View and manage your professional network
Follow Capability: Follow professionals without direct connections
Real-time Updates: Stay informed about your network's activities
💼 Job Features
Job Discovery: Browse and search for relevant job opportunities
Job Application: Apply directly to positions within the platform
Application Tracking: Monitor the status of your job applications
Company Profiles: View detailed information about potential employers
💬 Communication
Real-time Notifications: Receive instant alerts for important activities
Push Notifications: Stay informed even when the app is in the background
Email Verification: Secure account creation with email verification
🔐 Security & Authentication
Multi-factor Authentication: Enhanced security with OTP verification
Password Management: Secure password reset and update functionality
Privacy Controls: Granular control over your data and visibility
🛠️ Technologies
Frontend
Flutter: Cross-platform UI toolkit for developing native interfaces
Dart: Programming language optimized for building mobile, desktop, and web applications
Riverpod: Reactive state management for Flutter applications
Go Router: Declarative routing solution for Flutter
Sizer: Responsive UI elements that adapt to different screen sizes
Backend & Services
Firebase Authentication: Secure user authentication with email and social login
Firebase Firestore: NoSQL cloud database for storing and syncing application data
Firebase Cloud Messaging: Cross-platform messaging solution
Firebase App Check: Added security layer to protect backend resources
Storage & Media
File Picker: Native file explorer for selecting media
Image Picker: Camera and gallery integration for profile pictures
Shared Preferences: Local data persistence for user settings
Flutter Secure Storage: Encrypted storage for sensitive information
Notifications
Flutter Local Notifications: In-app and system notifications
Push Notifications: Background messaging capabilities
Custom Notification Channels: Categorized notification delivery
UI/UX Components
Custom Widgets: Responsive and reusable UI components
Theming System: Consistent application styling with light/dark mode support
Material Design: Following Google's design guidelines for intuitive user experience


🚀 Getting Started
Prerequisites
Flutter SDK (latest stable version)
Android Studio or VS Code with Flutter plugins
Firebase project setup
Installation
Clone the repository:
```git clone https://github.com/yourusername/lockedin.git```
```cd lockedin```

Install dependencies:
```flutter pub get```

Configure Firebase:

Create a Firebase project
Add Android & iOS apps to your Firebase project
Download and place the configuration files
Enable Authentication, Firestore, and Cloud Messaging
Run the application:
flutter run
``` flutter run```
🏗️ Architecture
LockedIn follows a feature-first architecture with clear separation of concerns:

Models: Data structures representing domain entities
Repositories: Data access layer abstracting backend communications
ViewModels: Business logic and state management
Views: UI components for rendering and user interaction
The application uses the Provider pattern for dependency injection and Riverpod for state management, enabling efficient data flow and UI updates.

🔄 Workflow
Authentication: Users register/login with email verification
Profile Creation: Users create or update their professional profile
Networking: Connect with other professionals
Job Exploration: Discover and apply for job opportunities
Notifications: Receive updates about connections and applications
🤝 Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

LockedIn - Building professional connections that matter
