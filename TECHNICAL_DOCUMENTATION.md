# 📄 Smart Logo Maker - Technical Documentation

Assalam-o-Alaikum! Ye document aapko is Flutter project ki gehrayi aur workflow samajhne mein madad karega.

---

## 🚀 1. Project Workflow (App Kaise Chalti Hai?)

App ka poora flow in steps par mushtamil hai:

1.  **Start-up**: `main.dart` chalta hai jo Supabase aur Environment variables ko set karta hai.
2.  **Authentication**: User login ya signup karta hai (`log_in_screen.dart`). Baghair login ke bhi app chalti hai magar design save karne ke liye login zaroori hai.
3.  **Home Dashbaord**: User ko teen options milte hain:
    *   **Auto Design**: AI-style entry form.
    *   **Create Logo**: Direct editor.
    *   **My Designs**: Cloud se purane designs fetch karna.
4.  **Editing (The Core)**: `download_logo.dart` screen par user canvas par elements add/delete/rotate/resize karta hai.
5.  **Export/Save**: Design final hone par `canvas_exporter.dart` ki madad se logo save kiya jata hai.

---

## 📱 2. Screen-by-Screen Breakdown

Yahan har screen ka maqsad aur file path diya gaya hai:

### **🏠 Dashboard Phase**
*   **Splash Screen** (`lib/screens/Splash_screen.dart`): Initial loading.
*   **Home Screen** (`lib/screens/home_screen.dart`): Main navigation hub.
*   **Design Input** (`lib/screens/design_input_screen.dart`): User se text aur slogan lene ke liye form.

### **🎨 Editing Phase (The Heart of App)**
*   **Logo Editor** (`lib/screens/download_logo.dart`): Ye screen sab se bari hai. Ismein `LogoCanvas` widget use hota hai.
*   **Art Selection** (`lib/screens/art_select_screen.dart`): Graphics select karne ke liye.
*   **Color Picker** (`lib/screens/color_screen.dart`): Text aur icons ke rang badalne ke liye.
*   **Gradient Picker** (`lib/screens/gradiant_picker_screen.dart`): Smooth multi-colors ke liye.
*   **Layer Panel** (`lib/screens/layer_panel.dart`): Kaunsa element upar rahega aur kaunsa neeche.

### **💾 Storage & Account Phase**
*   **My Account** (`lib/screens/my_account_screen.dart`): User profile aur logout.
*   **My Designs** (`lib/screens/my_design_screen.dart`): Supabase se user ke banaye huay logos dikhata hai.

---

## 🛠 3. Important Concepts for Beginners

Agar aap beginner hain toh ye 3 cheezein zaroori samjhein:

1.  **State Management (Provider)**: Color badalne par editor screen kaise update hoti hai? Ye `SelectedColorProvider` handle karta hai.
2.  **Custom Painting**: Logo ko draw karne ke liye `CustomPainter` aur `Canvas` API ka use kiya gaya hai.
3.  **Supabase Database**: Firebase ki tarah hai, jo user ke data ko SQL table mein save karta hai.
4.  **Gallery Saver**: Image ko phone ki gallery mein save karne wala plugin.

---

## 📦 4. Lib Folder Ki Structure

*   **/components**: Chote chote widgets (jese custom buttons, panels).
*   **/models**: Data structures (Logo elements ki properties).
*   **/services**: Backend se rabta (Auth, API calls, Ads).
*   **/utils**: Helpful functions (Theme colors, font utilities).

---

> **Note**: Is project ka main editor `download_logo.dart` hai. Agar aapko editing logic mein tabdeeli kani ho toh wahan se start karein.

Happy Coding! 🚀
