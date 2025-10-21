# 📖 User Manual - Mujawar Poultry Farm Management App

## 🎯 App Overview

This app helps you manage your poultry farm transactions, automatically send SMS notifications to customers, and maintain complete records with backup capabilities.

---

## 🚀 Getting Started

### First Time Login

1. Open the app
2. Enter your credentials:
   - **Email**: admin@mujawarpoultry.com
   - **Password**: (provided by admin)
3. Click **Login**

---

## 📱 Main Features

### 1️⃣ Dashboard

The dashboard shows:
- **Total Sales**: All-time sales amount
- **Total Pending**: Outstanding payments
- **Total Customers**: Unique customer count
- **Total Transactions**: Number of transactions

**Quick Actions:**
- Add New Transaction
- View Transaction History

**Today's Transactions:** Recent transactions appear at the bottom

### 2️⃣ Add New Transaction

To record a customer purchase:

1. Click the **"+ Add Transaction"** button
2. Fill in the form:

#### Customer Information
- **Customer Name**: Enter customer's name (e.g., "Karim")
- **Mobile Number**: Enter 10-digit mobile number (e.g., 9876543210)

#### Transaction Details
- **Quantity**: Number of items (e.g., 4)
- **Kilogram**: Total weight in kg (e.g., 4.5)
- **Rate**: Price per kg (e.g., 125)

**Auto-Calculated:**
- **Total Amount**: Automatically calculated (Kilogram × Rate)

#### Payment Details
- **Paid Amount**: Amount customer paid (e.g., 100)

**Auto-Calculated:**
- **Pending Amount**: Automatically calculated (Total - Paid)

3. Click **"Save Transaction"**

**What Happens Next:**
- Transaction is saved to database
- SMS is automatically sent to customer
- You return to dashboard with updated statistics

#### SMS Message Format

Customer receives:
```
Mujawar Poultry Farm:
Dear Karim,
You purchased 4.5 kg (Qty: 4) @ ₹125/kg.
Total: ₹562.50
Paid: ₹100
Pending: ₹462.50
Thank you for your purchase!
```

### 3️⃣ View Transaction History

Access complete transaction records:

1. From Dashboard, click **"View Transaction History"**
2. Use filters to view:
   - **All**: All transactions
   - **Today**: Today's transactions only
   - **Last 7 Days**: Past week
   - **Last 30 Days**: Past month

#### Transaction Details

Each transaction card shows:
- Customer name and mobile
- Total amount (in green)
- Pending amount (in orange, if any)
- Quantity, weight, rate, time

**To View Full Details:**
- Tap on any transaction card
- Bottom sheet opens with complete information
- View the SMS message that was sent

### 4️⃣ Backup & Export

Protect your data with regular backups:

1. Click **Backup icon** (📦) in top-right
2. Choose export format:
   - **Excel (.xlsx)**: Formatted spreadsheet
   - **JSON**: Raw data format
   - **CSV**: Comma-separated values

3. File is generated and sharing options appear
4. Save to:
   - Google Drive
   - WhatsApp
   - Email
   - Local storage

**Recommended:** Export weekly backups to Google Drive

---

## 💡 Usage Tips

### Daily Workflow

**Morning:**
1. Login to app
2. Check dashboard for pending payments

**During Sales:**
1. After each sale, immediately add transaction
2. Customer receives SMS instantly
3. Record is saved automatically

**Evening:**
1. Review today's transactions
2. Check total sales and pending amounts

**Weekly:**
1. Export backup to secure location
2. Review transaction history
3. Follow up on pending payments

### Best Practices

✅ **DO:**
- Add transactions immediately after sale
- Verify mobile number before saving
- Take weekly backups
- Review pending amounts regularly

❌ **DON'T:**
- Delay adding transactions (data may be forgotten)
- Share admin password
- Delete app without backup
- Ignore pending payments

---

## 🔍 Understanding the Dashboard

### Summary Cards

1. **Total Sales (Green)**
   - Lifetime revenue
   - Sum of all transaction amounts

2. **Total Pending (Orange)**
   - Outstanding payments
   - Money owed by customers

3. **Total Customers (Blue)**
   - Unique customers
   - Based on mobile numbers

4. **Total Transactions (Green)**
   - Number of sales recorded
   - All-time count

---

## 📊 Reports & Analytics

### Filter Transactions

**By Date Range:**
- Today: Current day sales
- Last 7 Days: Weekly summary
- Last 30 Days: Monthly overview
- All: Complete history

**Transaction Grouping:**
- Transactions are grouped by date
- Most recent appear first
- Easy to find specific dates

---

## 🔒 Security & Privacy

### Data Protection

- All data stored securely in Firebase
- Only admin can access the app
- Customer data is encrypted
- SMS sent directly from your phone

### Changing Password

To change admin password:
1. Go to Firebase Console
2. Authentication > Users
3. Find admin user
4. Click options (⋮) > Reset Password
5. Enter new password

---

## ❓ Frequently Asked Questions

### Q: Can I edit a transaction after saving?

**A:** Currently, transactions cannot be edited to maintain record integrity. If needed, contact the developer to add this feature.

### Q: What if SMS is not sent?

**A:** SMS requires:
- Physical Android device (not emulator)
- SMS permission granted
- Valid 10-digit mobile number
- Active SIM card

Check if permission is granted in phone settings.

### Q: Can I delete a transaction?

**A:** For data integrity, deletion is not available. You can mark it as cancelled by adding a note in future versions.

### Q: How much data can the app store?

**A:** Firebase free tier allows:
- 1 GB storage
- 50,000 reads/day
- 20,000 writes/day

This is sufficient for years of transactions.

### Q: Can multiple admins use the app?

**A:** Currently supports single admin. Multi-admin support can be added in future updates.

### Q: Is internet required?

**A:** Yes, internet is required for:
- Firebase authentication
- Saving transactions
- Viewing transaction history

Offline mode can be added in future versions.

### Q: Can customers view their transactions?

**A:** Currently admin-only. Customer portal can be added in future updates.

---

## 🛠️ Troubleshooting

### Login Issues

**Problem:** Cannot login
**Solutions:**
- Check internet connection
- Verify email and password
- Try "Forgot Password"
- Contact admin

### SMS Not Sending

**Problem:** SMS not received by customer
**Solutions:**
- Grant SMS permission in phone settings
- Check if mobile number is correct (10 digits)
- Ensure you're using physical device
- Check if SIM card is active

### App Crashes

**Problem:** App closes unexpectedly
**Solutions:**
- Update to latest version
- Clear app cache
- Restart phone
- Reinstall app (after backup)

### Data Not Saving

**Problem:** Transaction not saved
**Solutions:**
- Check internet connection
- Ensure all fields are filled
- Check Firebase connection
- Try again

---

## 📞 Support

For technical support or feature requests:
- Email: [Your Email]
- Phone: [Your Phone]

---

## 🆕 Future Updates

Planned features:
- [ ] Edit/Delete transactions
- [ ] Customer login portal
- [ ] WhatsApp notifications
- [ ] Offline mode
- [ ] Chart-based reports
- [ ] Print invoice
- [ ] Multiple admin support
- [ ] Payment reminders

---

## 📝 Version History

**Version 1.0.0** (October 18, 2025)
- Initial release
- Add transaction
- SMS notifications
- Transaction history
- Backup/Export
- Firebase integration

---

**Thank you for using Mujawar Poultry Farm Management App!** 🐔

For any questions or feedback, please contact support.

---

**App Version**: 1.0.0  
**Last Updated**: October 18, 2025
