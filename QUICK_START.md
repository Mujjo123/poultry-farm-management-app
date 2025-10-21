# ⚡ QUICK START CARD - Mujawar Poultry Farm App

## 🚀 3-Step Setup (First Time)

### 1️⃣ Install Dependencies
```bash
cd e:\Poultary_from
flutter pub get
```

### 2️⃣ Setup Firebase
1. Visit https://console.firebase.google.com/
2. Create new project: "Mujawar Poultry Farm"
3. Add Android app
   - Package: `com.mujawar.poultry_farm`
   - Download `google-services.json`
   - Place in: `android/app/google-services.json`
4. Enable **Authentication** → Email/Password
5. Enable **Firestore Database** → Start in production mode
6. Add Security Rules:
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
7. Create Admin User:
   - Go to Authentication → Users → Add User
   - Email: `admin@mujawarpoultry.com`
   - Password: `Admin@123` (or your choice)

### 3️⃣ Run the App
```bash
flutter run
```

---

## 📱 Daily Usage (Quick Reference)

### Login
- Email: `admin@mujawarpoultry.com`
- Password: (your admin password)

### Add Transaction (5 steps)
1. Click **+ Add Transaction** button
2. Enter customer name and mobile (10 digits)
3. Enter quantity, kilogram, rate
4. Enter paid amount
5. Click **Save** → SMS sent automatically!

### View Statistics
- Dashboard shows: Total Sales, Pending, Customers, Transactions
- Auto-updates in real-time

### View History
- Click "View Transaction History"
- Filter: All / Today / Last 7 Days / Last 30 Days
- Tap any transaction to see full details

### Export Backup
1. Click backup icon (top-right)
2. Choose: Excel / JSON / CSV
3. Share via WhatsApp, Drive, Email, etc.

---

## 🎯 Key Features at a Glance

| Feature | How to Access |
|---------|--------------|
| 📊 Dashboard | Home screen after login |
| ➕ Add Transaction | FAB button or Quick Actions card |
| 📜 View History | Dashboard → "View Transaction History" |
| 💾 Backup Data | Top-right backup icon |
| 📱 Auto SMS | Sent automatically when transaction saved |
| 🔓 Logout | Top-right logout icon |

---

## 🔢 Auto-Calculations

```
Total Amount = Kilogram × Rate
Pending Amount = Total Amount - Paid Amount
Total + Pending = Total Amount + Pending Amount
```

These calculate **automatically as you type**!

---

## 📨 SMS Format

```
Mujawar Poultry Farm:
Dear [Customer Name],
You purchased [Kg] kg (Qty: [Quantity]) @ ₹[Rate]/kg.
Total: ₹[Total]
Paid: ₹[Paid]
Pending: ₹[Pending]
Thank you for your purchase!
```

---

## ⚙️ Common Commands

### Install Dependencies
```bash
flutter pub get
```

### Run in Debug Mode
```bash
flutter run
```

### Build Release APK
```bash
flutter build apk --release
```

### Clean Build
```bash
flutter clean
flutter pub get
flutter run
```

### Check Flutter Setup
```bash
flutter doctor
```

---

## 🐛 Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| Can't login | Check internet, verify email/password |
| SMS not sent | Grant SMS permission, use physical device |
| Build error | Run `flutter clean && flutter pub get` |
| Firebase error | Check `google-services.json` is in `android/app/` |
| Data not saving | Check internet connection |

---

## 📂 Important Files

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry point |
| `android/app/google-services.json` | Firebase config (you add this) |
| `lib/utils/constants.dart` | App colors, strings |
| `SETUP_GUIDE.md` | Detailed setup instructions |
| `USER_MANUAL.md` | Complete user guide |

---

## 🎨 Customize App

### Change App Colors
Edit: `lib/utils/constants.dart`
```dart
static const Color primary = Color(0xFF2E7D32); // Change this
```

### Change App Name
Edit: `android/app/src/main/AndroidManifest.xml`
```xml
android:label="Your App Name"
```

### Change SMS Message
Edit: `lib/models/transaction_model.dart`
```dart
String generateSmsMessage() {
  return '''Your custom message here''';
}
```

---

## 📞 Need Help?

1. **Setup Issues?** → Read `SETUP_GUIDE.md`
2. **How to use?** → Read `USER_MANUAL.md`
3. **Understand code?** → Check code comments
4. **Rebuild with AI?** → Use `AI_DEVELOPER_PROMPT.md`

---

## ✅ Pre-Flight Checklist

Before first run:
- [ ] Flutter installed (`flutter doctor`)
- [ ] Firebase project created
- [ ] `google-services.json` added
- [ ] Authentication enabled
- [ ] Firestore enabled
- [ ] Security rules added
- [ ] Admin user created
- [ ] Dependencies installed (`flutter pub get`)

---

## 🎯 Project Info

- **Package:** com.mujawar.poultry_farm
- **Min SDK:** Android 5.0 (API 21)
- **Target SDK:** Android 14 (API 34)
- **Version:** 1.0.0
- **Technology:** Flutter + Firebase

---

## 📊 File Locations

```
e:\Poultary_from\
├── lib/                    # App code
├── android/               # Android config
│   └── app/
│       └── google-services.json  # ADD THIS FILE
├── SETUP_GUIDE.md         # Read for setup
├── USER_MANUAL.md         # Read for usage
└── pubspec.yaml           # Dependencies
```

---

## 🔐 Default Credentials (Change These!)

**Admin Login:**
- Email: `admin@mujawarpoultry.com`
- Password: `Admin@123`

**⚠️ IMPORTANT:** Change password after first login!

---

## 📱 APK Location (After Build)

```
build/app/outputs/flutter-apk/app-release.apk
```

Share this file to install on other devices.

---

## 🌐 Firebase Console

Access anytime: https://console.firebase.google.com/

**What you can do:**
- View all transactions (Firestore)
- Manage admin users (Authentication)
- Check app usage (Analytics)
- Update security rules

---

## 🎓 Learning Path

1. ✅ **Setup** → Follow `SETUP_GUIDE.md`
2. ✅ **Usage** → Read `USER_MANUAL.md`
3. ✅ **Code** → Explore `lib/` folder
4. ✅ **Modify** → Change colors, text, features
5. ✅ **Extend** → Add new features

---

## 💾 Backup Recommendations

- **Daily:** Use app's export feature
- **Weekly:** Export to Google Drive
- **Monthly:** Download from Firebase Console

---

## 📈 Success Metrics

Your app is working if:
- ✅ Can login successfully
- ✅ Can add transactions
- ✅ SMS sent to customers
- ✅ Dashboard shows statistics
- ✅ Can view history
- ✅ Can export backup

---

## 🚀 What's Next?

After setup:
1. Test with dummy data
2. Train admin user
3. Start daily operations
4. Take weekly backups
5. Monitor business growth!

---

**🎉 You're Ready to Go! Happy Farming! 🐔**

---

**Quick Reference Version:** 1.0  
**Last Updated:** October 18, 2025  
**Print this card for easy reference!**
