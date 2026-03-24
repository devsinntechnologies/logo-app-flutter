# 🎨 Smart Logo Maker - Project Guide (Beginner Friendly)

Assalam-o-Alaikum! Agar aap Flutter mein beginner hain, toh ye guide aapko is project ka ek-ek hissa samajhne mein madad karegi. Ye project ek **Logo Designer App** hai jahan users apna logo khud bana sakte hain.

---

## 📂 Project Structure (Folders Kia Hain?)

Is project mein `lib` folder sabse important hai. Iske andar codes ko partitions mein divide kiya gaya hai:

1.  **`main.dart`**: App ka entry point. Sabse pehle ye file chalti hai. Ye Supabase (Database) aur Ads ko initialize karti hai.
2.  **`screens/`**: Ismein saari mobile screens hain (Home, Login, Editor, etc.).
3.  **`models/`**: Ismein data structures hain. Maslan, ek "Logo" mein kia kia hota hai (position, color, size), wo yahan define hota hai.
4.  **`services/`**: Ismein backend logic hai (Database se connect karna, Ads show karna, Internet check karna).
5.  **`provider/`**: Ye "State Management" ke liye use hota hai. Maslan, agar aap ek screen par color change karte hain toh dusri screen ko kaise pata chalega? Wo `provider` handle karta hai.
6.  **`components/`**: Reusable widgets. Maslan, Buttons ya Custom Canvas jo har jagah use ho sakein.

---

## 📱 Screens Ka Detailed Overview

Yahan bataya gaya hai ke har screen kia kaam karti hai:

### 1. **Splash Screen (`Splash_screen.dart`)**
*   **Kaam:** Jab app open hoti hai toh logo nazar aata hai aur backend ki tayyari hoti hai. Iske baad ye Home Screen par bhej deti hai.

### 2. **Home Screen (`home_screen.dart`)**
*   **Kaam:** Ye app ka main dashboard hai.
*   **Features:**
    *   **Auto Design Button:** User ko info entry screen par le jata hai.
    *   **Create Logo Button:** Khali canvas (Editor) kholta hai.
    *   **My Designs:** User ke puray save kiye huay designs dikhata hai.
    *   **Drawer:** Side menu jahan settings aur profile hoti hai.

### 3. **The Editor Screen (`download_logo.dart`)**
*   *Note: Iska naam `download_logo` hai magar ye asal mein poora **Logo Editor** hai.*
*   **Kaam:** Sabse bari aur main screen. Yahan user:
    *   Text add karta hai.
    *   Shapes aur Icons move karta hai.
    *   Elements ko rotate aur resize karta hai.
    *   **Undo/Redo** karta hai.
    *   Direct save ya gallery mein export karta hai.

### 4. **Auth Screens (`log_in_screen.dart` & `sign_up_screen.dart`)**
*   **Kaam:** User ko register aur login karne ke liye. Ismein **Google Sign-In** bhi integrated hai.

### 5. **Design Input (`design_input_screen.dart`)**
*   **Kaam:** Jab user "Auto Design" choose karta hai, toh yahan wo Company Name aur Slogan likhta hai.

### 6. **Art & Image Selection**
*   **`art_select_screen.dart`**: Logo ke liye icons/graphics select karne ke liye.
*   **`select_bg_images.dart`**: Background images lagane ke liye.

### 7. **Panels (Utilities)**
*   **`layer_panel.dart`**: Shapes ko aage ya peeche (order) karne ke liye.
*   **`movement_panel.dart`**: Ungli se move karne ke bajaye buttons se bariqi se move karne ke liye.

---

## ⚙️ Backend & Logic (Services)

*   **`auth_service.dart`**: Login/Logout ka sara kaam handle karti hai.
*   **`user_design_service.dart`**: User ke designs ko **Supabase** (Database) mein save aur wahan se load karti hai.
*   **`ad_mob_service.dart`**: App mein Google Ads manage karti hai.
*   **`canvas_exporter.dart`**: Aapke banaye huay logo ko Image (PNG/JPG) mein convert karke phone mein save karti hai.

---

## 🛠 Beginner Tips (Aapko kia chahye?)

1.  **State Management**: Is project mein `Provider` use ho raha hai. Isko samajhne ki koshish karein.
2.  **RepaintBoundary**: `download_logo.dart` mein use hua hai, jo canvas ka screenshot lekar image banata hai.
3.  **Supabase**: Ye Firebase ka alternative hai. Is app ka sara data wahan store hota hai.

---

Umeed hai ye guide aapke kaam aayegi! Kuch aur poochna ho toh zaroor batayein.
