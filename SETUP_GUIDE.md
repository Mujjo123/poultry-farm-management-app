# 🚀 Setup Guide - Mujawar Poultry Farm Management App

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

1. **Flutter SDK** (version 3.0 or higher)
   - Download from: https://flutter.dev/docs/get-started/install
   - Verify installation: `flutter doctor`

2. **Android Studio** or **VS Code** with Flutter extensions

3. **Git** (for version control)

4. **Firebase Account** (free tier is sufficient)

---

## 🔧 Step-by-Step Installation

### Step 1: Clone or Extract the Project

```bash
cd e:\Poultary_from
```

### Step 2: Install Flutter Dependencies

```bash
flutter pub get
```

### Step 3: Firebase Setup

#### 3.1 Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project"
3. Enter project name: `Mujawar Poultry Farm`
4. Disable Google Analytics (optional)
5. Click "Create Project"

#### 3.2 Add Android App to Firebase

1. In Firebase Console, click on "Android" icon
2. Enter Android package name: `com.mujawar.poultry_farm`
3. Enter App nickname: `Poultry Farm`
4. Click "Register App"
5. **Download `google-services.json`**
6. Place the file in: `android/app/google-services.json`

#### 3.3 Enable Firebase Authentication

1. In Firebase Console, go to **Authentication**
2. Click "Get Started"
3. Enable **Email/Password** sign-in method
4. Click "Save"

#### 3.4 Enable Cloud Firestore Database

1. In Firebase Console, go to **Firestore Database**
2. Click "Create Database"
3. Start in **Production Mode**
4. Choose your server location (closest to your region)
5. Click "Enable"

#### 3.5 Configure Firestore Security Rules

Go to **Firestore Database > Rules** and replace with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /transactions/{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

Click "Publish"

### Step 4: Create Admin User

You need to create an admin user account. You have two options:

#### Option A: Using Firebase Console (Recommended)

1. Go to **Authentication > Users** in Firebase Console
2. Click "Add User"
3. Enter email: `admin@mujawarpoultry.com`
4. Enter password: `Admin@123` (or your choice)
5. Click "Add User"

#### Option B: Using the App (First Time Only)

Temporarily modify the app to create an admin account:

1. In `lib/screens/login_screen.dart`, add a signup button
2. Run the app and create the admin account
3. Remove the signup button after creating the account

### Step 5: Configure Android Permissions

The `AndroidManifest.xml` is already configured with necessary permissions:
- SEND_SMS (for sending SMS notifications)
- READ_SMS / RECEIVE_SMS (optional, for SMS verification)
- INTERNET (for Firebase connectivity)
- WRITE_EXTERNAL_STORAGE (for backup exports)

### Step 6: Build and Run

#### For Development (Debug Mode)

```bash
flutter run
```

#### For Production (Release APK)

```bash
flutter build apk --release
```

The APK will be generated at: `build/app/outputs/flutter-apk/app-release.apk`

---

## 📱 SMS Configuration

### Option 1: Android SmsManager (Default - Free)

The app uses native Android SMS functionality. No additional setup required.

**Requirements:**
- Physical Android device (SMS doesn't work on emulator)
- SMS permission granted at runtime

### Option 2: Twilio API (Optional - Paid)

For cloud-based SMS or iOS support:

1. Create account at [Twilio](https://www.twilio.com/)
2. Get your Account SID and Auth Token
3. Create `.env` file in project root:

```env
TWILIO_ACCOUNT_SID=your_account_sid
TWILIO_AUTH_TOKEN=your_auth_token
TWILIO_PHONE_NUMBER=your_twilio_number
```

4. Modify `lib/services/sms_service.dart` to use Twilio API

---

## 🧪 Testing the App

### Login Credentials

Use the admin credentials you created:
- **Email**: `admin@mujawarpoultry.com`
- **Password**: `Admin@123`

### Test Flow

1. **Login** with admin credentials
2. **Add Transaction**:
   - Customer Name: Test Customer
   - Mobile: 9876543210
   - Quantity: 5
   - Kilogram: 10
   - Rate: 150
   - Paid Amount: 1000
3. **Check if SMS is sent** (requires physical device)
4. **View Dashboard** statistics
5. **View Transaction History**
6. **Export Backup** (Excel/JSON/CSV)

---

## 🔒 Security Best Practices

1. **Change default admin password** immediately
2. **Update Firestore security rules** for production
3. **Enable Firebase App Check** (optional)
4. **Use environment variables** for sensitive data
5. **Regular database backups**

---

## 📦 Building for Production

### 1. Update App Version

In `pubspec.yaml`:
```yaml
version: 1.0.0+1
```

### 2. Generate App Icon (Optional)

Use [App Icon Generator](https://appicon.co/) to create icons

### 3. Create Release APK

```bash
flutter build apk --release --split-per-abi
```

This creates optimized APKs for different CPU architectures:
- `app-armeabi-v7a-release.apk` (32-bit ARM)
- `app-arm64-v8a-release.apk` (64-bit ARM)
- `app-x86_64-release.apk` (64-bit x86)

### 4. Test Release Build

```bash
flutter install --release
```

---

## 🐛 Troubleshooting

### Issue: "google-services.json not found"

**Solution**: Ensure the file is placed in `android/app/google-services.json`

### Issue: "FirebaseException: No Firebase App"

**Solution**: 
- Check if `google-services.json` is correctly configured
- Rebuild the app: `flutter clean && flutter pub get`

### Issue: "SMS not sending"

**Solution**:
- Check SMS permission is granted
- Test on physical device (not emulator)
- Verify phone number format (10 digits)

### Issue: "Build failed with Gradle error"

**Solution**:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Issue: "Firebase Auth not working"

**Solution**:
- Verify Email/Password is enabled in Firebase Console
- Check internet connectivity
- Ensure Firestore rules allow authenticated access

---

## 📞 Support

For issues or questions:
- Check the [README.md](README.md) file
- Review Firebase documentation
- Contact: [Your Contact Information]

---

## ✅ Deployment Checklist

- [ ] Firebase project created
- [ ] google-services.json added
- [ ] Authentication enabled
- [ ] Firestore database enabled
- [ ] Security rules configured
- [ ] Admin user created
- [ ] App tested on physical device
- [ ] SMS functionality verified
- [ ] Backup/export tested
- [ ] Release APK built
- [ ] App signed (for Play Store)

---

**🎉 Congratulations! Your Poultry Farm Management App is ready to use!**

---

**Version**: 1.0.0  
**Last Updated**: October 18, 2025
