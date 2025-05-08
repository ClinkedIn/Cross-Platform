# LockedIn <img alt="LockedIn Logo" src="https://upload.wikimedia.org/wikipedia/commons/c/ca/LinkedIn_logo_initials.png" width="24" height="24">

**LockedIn** is a cross-platform professional networking application built with **Flutter** that enables users to connect, share professional experiences, and discover job opportunities. The platform offers a comprehensive suite of features for career development and professional networking.

---

## ✨ Features

### 👤 User Profiles

* **Comprehensive Profiles**: Create and customize detailed professional profiles
* **Experience & Education**: Showcase your work history and educational background
* **Skills Showcase**: Highlight your technical and professional skills
* **Profile Privacy Settings**: Control who can view your profile

### 🔗 Networking

* **Connection Management**: Send, accept, or reject connection requests
* **Network Visualization**: View and manage your professional network
* **Follow Capability**: Follow professionals without direct connections
* **Real-time Updates**: Stay informed about your network's activities

### 💼 Job Features

* **Job Discovery**: Browse and search for relevant job opportunities
* **Job Application**: Apply directly to positions within the platform
* **Application Tracking**: Monitor the status of your job applications
* **Company Profiles**: View detailed information about potential employers

### 💬 Communication

* **Real-time Notifications**
* **Push Notifications**: Stay informed even when the app is in the background
* **Email Verification**: Secure account creation

### 🔐 Security & Authentication

* **Multi-factor Authentication** (OTP support)
* **Password Management**: Secure password reset and update
* **Privacy Controls**: Fine-grained control over your data and visibility

---

## 🛠️ Technologies

### Frontend

* **Flutter** – Cross-platform UI toolkit
* **Dart** – Language for Flutter apps
* **Riverpod** – State management
* **Go Router** – Declarative navigation
* **Sizer** – Responsive UI layout

### Backend & Services

* **Firebase Authentication** – Email & social login
* **Firebase Firestore** – Real-time NoSQL database
* **Firebase Cloud Messaging** – Push notifications
* **Firebase App Check** – Security against abuse

### Storage & Media

* **File Picker** – Native file access
* **Image Picker** – Camera and gallery integration
* **Shared Preferences** – Local key-value storage
* **Flutter Secure Storage** – Encrypted local storage

### Notifications

* **Flutter Local Notifications** – Custom in-app alerts
* **Push Notifications** – Background alerts
* **Custom Notification Channels** – Categorized delivery

### UI/UX Components

* **Custom Widgets** – Reusable, responsive UI elements
* **Theming System** – Light/dark mode
* **Material Design** – Consistent UI/UX

---

## 🚀 Getting Started

### ✅ Prerequisites

* Flutter SDK (latest stable)
* Android Studio or VS Code (with Flutter plugins)
* A Firebase project

### 📦 Installation

```bash
# Clone the repository
git clone https://github.com/tahaaa22/ClinkedIn/Cross-Platform.git
cd Cross-Platform

# Install dependencies
flutter pub get
```

### 🔧 Firebase Setup

1. Create a Firebase project
2. Add Android & iOS apps to the Firebase project
3. Download and place `google-services.json` and `GoogleService-Info.plist` into appropriate directories
4. Enable:

   * Firebase Authentication
   * Firestore
   * Cloud Messaging

### ▶️ Run the App

```bash
flutter run
```

---

## 🏗️ Architecture

LockedIn uses a **feature-first architecture** with a clean separation of concerns:

* **Models** – Data structures representing domain entities
* **Repositories** – Abstract backend communication
* **ViewModels** – Business logic and state
* **Views** – UI components

State management is handled using **Riverpod**, and **Provider** is used for dependency injection.

---

## 🔄 Workflow

1. **Authentication** – Email sign-up/login with verification
2. **Profile Creation** – Build out your professional profile
3. **Networking** – Connect or follow other professionals
4. **Job Exploration** – Discover and apply for jobs
5. **Notifications** – Get updates on connections and job status

---

## 🤝 Contributing

Contributions are welcome!
Feel free to fork the repo and submit a Pull Request.

---

> **LockedIn** – *Building professional connections that matter.*

