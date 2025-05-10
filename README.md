# 🌾 AgriVision – Advnanced System for Modern Agriculture

AgriVision is a comprehensive mobile application developed using
*Flutter* and *Firebase*. This project was designed as a final year capstone for
*Leeds Beckett University*, aiming to empower rural farmers, streamline trader operations, and enable admin oversight.
The app bridges gaps between producers and consumers in agriculture by integrating real-time order, guidance, and product management features.

---

## 🚀 Features

### 👩‍🌾 User Panel (Farmer)
- OTP-based user authentication via Firebase
- View and search products from multiple traders
- Place orders using e-Sewa or Cash on Delivery
- View order details, track delivery status
- View delivery location on an embedded map
- Access order history and help support

### 🧑‍🌾 Trader Panel
- Register via OTP + Admin approval
- Add and manage farm products (image, price, quantity)
- Track incoming orders with real-time status updates
- Change status: Pending → Delivered / Cancelled
- View climate and crop guidance via Firebase
- Access government Anudan messages and support tools

### 🛡️ Admin Panel
- Approve/reject traders
- Manage global notifications
- View all user/trader accounts and contact messages
- Verify products before they're visible to users

---

## 🛠️ Tech Stack

| Technology        | Purpose                            |
|-------------------|-------------------------------------|
| Flutter           | Cross-platform mobile development  |
| Firebase Auth     | Email/OTP-based authentication     |
| Firestore         | NoSQL database for real-time data  |
| Firebase Storage  | Upload and retrieve product images |
| Google Maps API   | Map delivery and location display  |
| e-Sewa SDK        | Payment processing integration     |

---

## 🔐 Firestore Collections

- users – Registered users and traders
- products – Product listing by traders
- orders – All placed orders
- notifications – Admin-sent alerts
- contact_messages – Support queries
- crop_recommendations – Month-wise and region-wise crop advice
- climate_guidance – Dynamic tips based on weather and season
- anudan_messages – Government aid announcements

---

## 📦 Folder Structure


lib/
├── models/
├── screens/
│   ├── admin/
│   ├── trader/
│   └── user/
├── utiles/
├── widgets/
└── main.dart


---


## 🧪 Testing

- Verified user and trader role separation
- Manual testing for order creation and updates
- Firebase rules enforced to prevent unauthorized access
- PayPal integration sandbox-tested
- Responsiveness tested across multiple devices and orientations

---

## 🔮 Future Roadmap

- Introduce multilingual UI (Nepali, Hindi, English)
- Add weather API-based crop recommendations
- Chat support between traders and farmers
- AI-based demand prediction for produce

---

## 🧑‍🎓 Developer Info

*Satendra Kushwaha*  
Final Year BSc (Hons) Computing Student  
Leeds Beckett University
ID: 77356760  
📧 Email: ksatendra21@tbc.edu.np


---

## 📄 License

This project is licensed under the MIT License. Use permitted for academic and educational enhancements.
