# 🤖 AI DEVELOPER PROMPT - POULTRY FARM MANAGEMENT APP

## PROJECT TITLE
**Mujawar Poultry Farm Management App**

---

## 🎯 PROJECT GOAL

Build a mobile application where an admin can:
1. Add daily customer poultry purchase records
2. Automatically send SMS notifications to customers with purchase details
3. View transaction history with filters
4. Export/backup all data
5. Track sales, pending payments, and customer information

---

## 👥 USER ROLES

### Admin (Primary User)
- Login with email/password (Firebase Authentication)
- Add new customer transactions
- View dashboard with statistics
- View complete transaction history
- Export data backups (Excel/JSON/CSV)
- Logout securely

---

## 📋 DATA ENTRY FORM FIELDS

When admin adds a new transaction, the following fields are required:

| Field Name             | Input Type              | Validation                    | Example      | Notes                      |
|------------------------|-------------------------|-------------------------------|--------------|----------------------------|
| Sr. No.                | Auto Increment (UUID)   | Auto-generated                | 1            | Unique transaction ID      |
| Customer Name          | Text                    | Required, min 2 characters    | Karim        | Customer's full name       |
| Customer Mobile Number | Number (10 digits)      | Required, must be 10 digits   | 9876543210   | For SMS notification       |
| Quantity               | Integer                 | Required, > 0                 | 4            | Number of items            |
| Kilogram               | Decimal (max 2 places)  | Required, > 0                 | 4.5          | Total weight in kg         |
| Rate (₹/kg)            | Decimal (max 2 places)  | Required, > 0                 | 125          | Price per kilogram         |
| **Total Amount**       | **Auto-Calculated**     | Kilogram × Rate               | 562.50       | **Read-only field**        |
| Paid Amount            | Decimal (max 2 places)  | Required, ≤ Total Amount      | 100          | Amount customer paid       |
| **Pending Amount**     | **Auto-Calculated**     | Total Amount - Paid Amount    | 462.50       | **Read-only field**        |
| **Total + Pending**    | **Auto-Calculated**     | Total Amount + Pending Amount | 1025         | **Cumulative pending**     |
| Date                   | DateTime                | Auto (current date/time)      | 18/10/2025   | Transaction timestamp      |

### Auto-Calculation Logic

```
Total Amount = Kilogram × Rate
Pending Amount = Total Amount - Paid Amount
Total + Pending = Total Amount + Pending Amount
```

---

## 💬 SMS NOTIFICATION FEATURE

### When to Send
- Immediately after admin clicks "Save Transaction"
- Before navigating back to dashboard

### SMS Format (Plain Text)

```
Mujawar Poultry Farm:
Dear [Customer Name],
You purchased [Kilogram] kg (Qty: [Quantity]) @ ₹[Rate]/kg.
Total: ₹[Total Amount]
Paid: ₹[Paid Amount]
Pending: ₹[Pending Amount]
Thank you for your purchase!
```

### Example SMS

```
Mujawar Poultry Farm:
Dear Karim,
You purchased 4.5 kg (Qty: 4) @ ₹125/kg.
Total: ₹562.50
Paid: ₹100
Pending: ₹462.50
Thank you for your purchase!
```

### SMS Implementation Options

**Option 1 (Recommended for Android):**
- Use Android native `SmsManager` API
- Works offline (no API costs)
- Requires: `SEND_SMS` permission

**Option 2 (For iOS/Multi-platform):**
- Use Twilio API (paid service)
- Works on iOS and Android
- Requires: Twilio account, API credentials

---

## 💾 DATABASE REQUIREMENTS

### Technology
- **Firebase Firestore** (NoSQL Cloud Database)

### Database Structure

**Collection:** `transactions`

**Document Schema:**

```json
{
  "id": "uuid-string",
  "customerName": "Karim",
  "mobileNumber": "9876543210",
  "quantity": 4,
  "kilogram": 4.5,
  "rate": 125,
  "totalAmount": 562.50,
  "paidAmount": 100,
  "pendingAmount": 462.50,
  "totalWithPending": 1025,
  "date": "2025-10-18T14:30:00.000Z"
}
```

### Firestore Security Rules

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

---

## ⚙️ TECHNICAL REQUIREMENTS

### Platform
- **Primary:** Android
- **Secondary (Optional):** iOS

### Technology Stack

| Component             | Technology                              |
|-----------------------|-----------------------------------------|
| Framework             | Flutter (Dart)                          |
| UI Design             | Material Design 3                       |
| State Management      | Provider                                |
| Backend/Database      | Firebase Firestore                      |
| Authentication        | Firebase Auth (Email/Password)          |
| SMS Sending           | Android SmsManager / Twilio API         |
| Data Export           | Excel (xlsx), JSON, CSV                 |
| Local Storage         | path_provider                           |
| File Sharing          | share_plus                              |
| Permissions           | permission_handler                      |

### Required Flutter Packages

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  
  # UI
  google_fonts: ^6.1.0
  intl: ^0.18.1
  
  # SMS
  flutter_sms: ^2.3.3
  permission_handler: ^11.0.1
  
  # Export/Backup
  excel: ^4.0.2
  path_provider: ^2.1.1
  share_plus: ^7.2.1
  
  # State Management
  provider: ^6.1.1
  
  # Utilities
  uuid: ^4.2.2
  fluttertoast: ^8.2.4
```

---

## 🖥️ APP SCREENS & FLOW

### 1. Login Screen
- **Fields:** Email, Password
- **Actions:** Login, Forgot Password
- **Navigation:** → Dashboard (on success)

### 2. Dashboard Screen
- **Sections:**
  - Welcome banner with date
  - Statistics cards (4 cards):
    - Total Sales (₹)
    - Total Pending (₹)
    - Total Customers (count)
    - Total Transactions (count)
  - Quick actions
  - Today's transactions list
- **Actions:** 
  - Add Transaction (FAB + Card)
  - View History
  - Backup/Export
  - Logout

### 3. Add Transaction Screen
- **Form Sections:**
  - Customer Information (Name, Mobile)
  - Transaction Details (Quantity, Kg, Rate)
  - Amount Details (Total auto, Paid, Pending auto)
- **Features:**
  - Real-time auto-calculation
  - Form validation
  - Loading state during save
  - SMS info banner
- **Actions:**
  - Save (validates → saves to DB → sends SMS → navigates back)
  - Cancel/Back

### 4. Transaction History Screen
- **Features:**
  - Filter chips (All, Today, 7 Days, 30 Days)
  - Grouped by date (Today, Yesterday, specific dates)
  - Search/filter dropdown
  - Pull-to-refresh
- **Transaction Card Shows:**
  - Customer avatar (first letter)
  - Name, mobile
  - Quantity, weight, rate, time
  - Total amount (green)
  - Pending amount (orange badge if > 0)
- **Actions:**
  - Tap card → View full details (bottom sheet)
  - Bottom sheet shows: All fields + SMS message preview

---

## 🎨 UI/UX DESIGN GUIDELINES

### Color Scheme

```
Primary Color: #2E7D32 (Dark Green)
Secondary Color: #4CAF50 (Green)
Accent Color: #8BC34A (Light Green)
Background: #F5F5F5 (Light Gray)
Card Background: #FFFFFF (White)

Status Colors:
- Success: #388E3C (Green)
- Pending: #F57C00 (Orange)
- Error: #D32F2F (Red)
- Text Primary: #212121 (Dark Gray)
- Text Secondary: #757575 (Gray)
```

### Typography
- **Font Family:** Google Fonts - Poppins
- **App Title:** 20px, Bold
- **Card Title:** 16px, Bold
- **Body Text:** 14px, Regular
- **Stats Numbers:** 20px, Bold

### Design Patterns
- **Cards:** Rounded corners (12px), elevation 2-3
- **Buttons:** Rounded (12px), padding 16px vertical
- **Input Fields:** Outlined, rounded (12px)
- **FAB:** Primary color, bottom-right position
- **Icons:** Material Icons, 24px standard

### Layout
- Clean, minimal design
- White cards on light gray background
- Consistent padding (16px)
- Proper spacing between elements
- Responsive to different screen sizes

---

## 📊 DASHBOARD STATISTICS LOGIC

### Total Sales
```dart
Sum of all transaction.totalAmount
```

### Total Pending
```dart
Sum of all transaction.pendingAmount
```

### Total Customers
```dart
Count of unique transaction.mobileNumber
```

### Total Transactions
```dart
Count of all transactions
```

---

## 📤 BACKUP & EXPORT FUNCTIONALITY

### Export Formats

#### 1. Excel (.xlsx)
- **Features:**
  - Formatted headers (bold, green background)
  - All transaction fields in columns
  - Auto-width columns
  - Professional appearance
- **Use Case:** Opening in Excel, Google Sheets

#### 2. JSON
- **Features:**
  - Raw data format
  - Includes all fields
  - Proper indentation
- **Use Case:** Data analysis, importing to other systems

#### 3. CSV
- **Features:**
  - Comma-separated values
  - Compatible with Excel
  - Simple text format
- **Use Case:** Importing to spreadsheets, databases

### Export Process
1. User clicks Backup icon
2. Choose format dialog appears
3. Show loading indicator
4. Generate file in app documents directory
5. Open share sheet (WhatsApp, Drive, Email, etc.)
6. Show success/error message

### File Naming Convention
```
Poultry_Transactions_DDMMYYYY_HHMMSS.ext

Example:
Poultry_Transactions_18102025_143000.xlsx
```

---

## 🔒 AUTHENTICATION & SECURITY

### Admin Login
- **Method:** Firebase Email/Password Authentication
- **Default Admin:**
  - Email: `admin@mujawarpoultry.com`
  - Password: Set during first-time setup

### Security Features
- Only authenticated users can access app
- Firestore rules restrict access to authenticated users only
- No public data exposure
- Secure logout functionality

### Password Requirements
- Minimum 6 characters
- Combination of letters and numbers recommended
- Stored securely in Firebase Auth

---

## 📱 PERMISSIONS REQUIRED

### Android Permissions (AndroidManifest.xml)

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.SEND_SMS"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

### Runtime Permissions
- **SMS:** Request when adding first transaction
- **Storage:** Request when exporting first backup

---

## 🔄 APP WORKFLOW (STEP-BY-STEP)

### Typical User Journey

```
1. App Launch
   ↓
2. Login Screen
   → Enter credentials → Authenticate with Firebase
   ↓
3. Dashboard
   → View statistics
   → See today's transactions
   ↓
4. Add Transaction (FAB click)
   → Fill customer info
   → Fill transaction details
   → Auto-calculate amounts
   → Click Save
   ↓
5. Save Process
   → Validate form
   → Generate UUID
   → Save to Firestore
   → Send SMS to customer
   → Show success message
   ↓
6. Return to Dashboard
   → Updated statistics
   → New transaction in list
   ↓
7. Optional Actions:
   - View History → See all transactions with filters
   - Export Backup → Choose format → Share file
   - Logout → Return to login screen
```

---

## ✅ VALIDATION RULES

### Customer Name
- Required field
- Minimum 2 characters
- Maximum 50 characters
- Allow letters and spaces

### Mobile Number
- Required field
- Exactly 10 digits
- Must start with 6, 7, 8, or 9 (Indian numbers)
- Only numeric input

### Quantity
- Required field
- Integer only
- Must be > 0

### Kilogram
- Required field
- Decimal allowed (max 2 decimal places)
- Must be > 0

### Rate
- Required field
- Decimal allowed (max 2 decimal places)
- Must be > 0

### Paid Amount
- Required field
- Decimal allowed (max 2 decimal places)
- Must be ≥ 0
- Cannot exceed Total Amount

---

## 🎯 SUCCESS CRITERIA

### App is successful if:

✅ Admin can login securely  
✅ Admin can add transactions with all required fields  
✅ Auto-calculations work correctly (Total, Pending)  
✅ SMS is sent automatically to customer after saving  
✅ Dashboard shows accurate real-time statistics  
✅ Transaction history displays all records with filters  
✅ Export functionality works for all formats (Excel, JSON, CSV)  
✅ Data persists in Firebase Firestore  
✅ App works offline for viewing (but requires internet for saving)  
✅ UI is clean, intuitive, and professional  
✅ No crashes or major bugs  
✅ Proper error handling and user feedback  

---

## 📦 DELIVERABLES

1. **Complete Flutter Project**
   - All source code files
   - Properly organized folder structure
   - Clean, commented code

2. **Firebase Integration**
   - Authentication setup
   - Firestore database configuration
   - Security rules implemented

3. **Documentation**
   - README.md (project overview)
   - SETUP_GUIDE.md (installation instructions)
   - USER_MANUAL.md (how to use the app)

4. **Build Files**
   - Debug APK for testing
   - Release APK for production
   - Screenshots of all screens

5. **Configuration Files**
   - pubspec.yaml (dependencies)
   - AndroidManifest.xml (permissions)
   - build.gradle (Firebase config)

---

## 🚀 OPTIONAL FUTURE ENHANCEMENTS

### Phase 2 Features (Not in MVP)

- [ ] Customer login portal
- [ ] WhatsApp integration for notifications
- [ ] Chart-based analytics (pie charts, bar graphs)
- [ ] Edit/Delete transactions
- [ ] Multiple admin users with roles
- [ ] Offline mode with sync
- [ ] Print invoice feature
- [ ] Payment reminders (auto SMS for pending payments)
- [ ] Customer transaction history view
- [ ] Dark mode support
- [ ] Multi-language support (Hindi, Marathi)

---

## 🧪 TESTING REQUIREMENTS

### Manual Testing Checklist

**Authentication:**
- [ ] Login with valid credentials
- [ ] Login with invalid credentials (show error)
- [ ] Logout functionality

**Add Transaction:**
- [ ] Add transaction with all valid data
- [ ] Validate empty fields (show errors)
- [ ] Auto-calculation works correctly
- [ ] SMS sent successfully
- [ ] Transaction saved to Firestore

**Dashboard:**
- [ ] Statistics calculate correctly
- [ ] Today's transactions display
- [ ] Pull-to-refresh updates data

**Transaction History:**
- [ ] All filters work (All, Today, Week, Month)
- [ ] Transactions grouped by date
- [ ] Tap card shows details
- [ ] Empty state shows properly

**Export:**
- [ ] Excel export generates correct file
- [ ] JSON export generates correct file
- [ ] CSV export generates correct file
- [ ] Share functionality works

---

## 📱 TARGET DEVICES

### Minimum Requirements
- **OS:** Android 5.0 (API 21) or higher
- **RAM:** 2 GB
- **Storage:** 100 MB free space
- **Screen:** 5-inch or larger

### Recommended
- **OS:** Android 10 or higher
- **RAM:** 4 GB
- **Storage:** 500 MB free space
- **Screen:** 6-inch or larger

---

## 🎓 DEVELOPER NOTES

### Code Quality Standards
- Follow Flutter best practices
- Use meaningful variable/function names
- Add comments for complex logic
- Implement error handling (try-catch)
- Use const constructors where possible
- Optimize performance (avoid unnecessary rebuilds)

### State Management
- Use Provider for global state
- Keep UI separate from business logic
- Use ChangeNotifier for reactive updates

### Firebase Best Practices
- Initialize Firebase in main()
- Handle Firebase exceptions properly
- Use StreamBuilder for real-time data
- Implement offline persistence (optional)

---

## 📞 SUPPORT & MAINTENANCE

### Documentation to Provide
1. How to update admin credentials
2. How to modify SMS message format
3. How to change app colors/theme
4. How to update Firebase configuration
5. Troubleshooting common issues

---

## 🎉 SUMMARY

Build a **professional, production-ready Flutter app** for managing poultry farm transactions with:

1. **Secure Admin Login** (Firebase Auth)
2. **Easy Transaction Entry** (with auto-calculations)
3. **Automatic SMS Notifications** (sent to customers)
4. **Real-time Dashboard** (with statistics)
5. **Complete Transaction History** (with filters)
6. **Data Backup/Export** (Excel, JSON, CSV)
7. **Clean, Intuitive UI** (Material Design)
8. **Reliable Firebase Backend** (Firestore database)

The app should be **stable, user-friendly, and ready for daily use** by the poultry farm admin to manage customer transactions efficiently.

---

**🚀 Ready to Build! Use this prompt with any AI App Builder (ChatGPT, Gemini, Bolt, Replit Agent, etc.)**

---

**Version:** 1.0  
**Date:** October 18, 2025  
**Project Name:** Mujawar Poultry Farm Management App  
**Package:** com.mujawar.poultry_farm
