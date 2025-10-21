# 🐔 Mujawar Poultry Farm Management App

## 📱 Project Overview

A professional Flutter-based mobile application for managing daily poultry farm transactions with automatic SMS notifications and comprehensive record-keeping.

## ✨ Key Features

- **Admin Authentication**: Secure login system using Firebase Auth
- **Transaction Management**: Add, view, and manage daily customer transactions
- **Auto Calculations**: Automatic calculation of total amount, pending amount, and cumulative totals
- **SMS Notifications**: Automatic SMS sent to customers after each transaction
- **Database Backup**: Firebase Firestore integration with export functionality
- **Dashboard Analytics**: Visual summary of sales, pending payments, and customer count

## 🎯 User Roles

### Admin
- Login with username/password
- Add new customer transactions
- View daily/monthly transaction history
- Download database backup (Excel/JSON)

## 📊 Transaction Data Fields

| Field | Type | Description |
|-------|------|-------------|
| Sr. No. | Auto Increment | Unique transaction ID |
| Customer Name | Text | Customer's name |
| Mobile Number | Number | 10-digit mobile number for SMS |
| Quantity | Number | Number of items |
| Kilogram | Number | Total weight in kg |
| Rate (₹/kg) | Number | Price per kilogram |
| Total Amount | Auto | Kilogram × Rate |
| Paid Amount | Number | Amount paid by customer |
| Pending Amount | Auto | Total - Paid |
| Pending + Total | Auto | Cumulative pending |
| Date | Auto | Transaction date |

## 🛠️ Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase Firestore
- **Authentication**: Firebase Auth
- **SMS Service**: Android SmsManager / Twilio API
- **Export**: Excel (xlsx) / JSON
- **Platform**: Android (Primary), iOS (Optional)

## 📋 Prerequisites

Before running this app, ensure you have:

1. Flutter SDK installed (3.0+)
2. Android Studio / VS Code with Flutter extensions
3. Firebase project created
4. `google-services.json` configured

## 🚀 Getting Started

### 1. Clone the repository
```bash
git clone <repository-url>
cd Poultary_from
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Configure Firebase
- Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
- Add Android app with package name: `com.mujawar.poultry_farm`
- Download `google-services.json` and place in `android/app/`
- Enable Firebase Authentication (Email/Password)
- Enable Cloud Firestore Database

### 4. SMS Setup (Choose one)

#### Option A: Android SmsManager (Offline - No cost)
- Add SMS permission in `AndroidManifest.xml`
- Works only on Android devices

#### Option B: Twilio API (Online - Paid)
- Create account at [Twilio](https://www.twilio.com/)
- Add credentials in `.env` file

### 5. Run the app
```bash
flutter run
```

## 📱 App Screenshots

*(Add screenshots here after development)*

## 📦 Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── transaction_model.dart   # Transaction data model
├── screens/
│   ├── login_screen.dart        # Admin login
│   ├── dashboard_screen.dart    # Home dashboard
│   ├── add_transaction_screen.dart  # Add new transaction
│   └── transaction_history_screen.dart  # View all transactions
├── services/
│   ├── auth_service.dart        # Firebase authentication
│   ├── database_service.dart    # Firestore operations
│   ├── sms_service.dart         # SMS sending logic
│   └── backup_service.dart      # Export functionality
├── widgets/
│   ├── custom_text_field.dart   # Reusable input field
│   └── summary_card.dart        # Dashboard cards
└── utils/
    └── constants.dart           # App constants
```

## 💬 SMS Message Format

```
Mujawar Poultry Farm:
Dear [Customer Name],
You purchased [Kilogram] kg (Qty: [Quantity]) @ ₹[Rate]/kg.
Total: ₹[Total Amount]
Paid: ₹[Paid Amount]
Pending: ₹[Pending Amount]
Thank you for your purchase!
```

## 🔒 Security

- Admin credentials stored securely in Firebase Auth
- Database rules configured for authenticated access only
- SMS permissions requested at runtime

## 📤 Backup & Export

Supported formats:
- **Excel (.xlsx)**: All transactions with formatting
- **JSON**: Raw data for external processing

## 🛣️ Roadmap

- [ ] Customer login portal
- [ ] WhatsApp integration
- [ ] Chart-based analytics
- [ ] Multi-admin support
- [ ] Print invoice feature
- [ ] Offline mode support

## 📄 License

This project is licensed under the MIT License.

## 👨‍💻 Developer

Developed for Mujawar Poultry Farm

## 🤝 Support

For issues or queries, contact: [Your Contact Information]

---

**Version**: 1.0.0  
**Last Updated**: October 18, 2025
