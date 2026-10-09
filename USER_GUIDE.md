# 📱 Trend Curve - Complete User Guide & Feature Manual (Hinglish)

> **"Track. Analyze. Grow."**  
> Ye document Trend Curve application ke har ek screen, har ek button, aur har ek feature ko detail me explain karta hai taaki aap is app ko 100% effectively use kar sakein.

---

## 📑 Index (Anukramanika)

1. [App Ka Main Maqsad (Purpose)](#1-app-ka-main-maqsad-purpose)
2. [PDF to Trend Curve & Excel Analyzer (Master Feature)](#2-pdf-to-trend-curve--excel-analyzer-master-feature)
3. [Splash & Onboarding Screens](#3-splash--onboarding-screens)
4. [Authentication (Login, Register & Password Reset)](#4-authentication-login-register--password-reset)
5. [Dashboard (Home Screen)](#5-dashboard-home-screen)
6. [Trends Management (Search, Filter, Sort & Cards)](#6-trends-management-search-filter-sort--cards)
7. [Naya Trend Create Karna (Create Trend Screen)](#7-naya-trend-create-karna-create-trend-screen)
8. [Trend Details & Analytics Screen](#8-trend-details--analytics-screen)
9. [Data Points Add, Edit & Delete Karna](#9-data-points-add-edit--delete-karna)
10. [Dedicated Analytics & Multi-Trend Comparison](#10-dedicated-analytics--multi-trend-comparison)
11. [Activity Timeline Log](#11-activity-timeline-log)
12. [Notifications Center](#12-notifications-center)
13. [Global Search Feature](#13-global-search-feature)
14. [Profile & User Settings](#14-profile--user-settings)
15. [Theme & Appearance (Dark Mode)](#15-theme--appearance-dark-mode)
16. [Data Sovereignty (Backup Export & Import)](#16-data-sovereignty-backup-export--import)
17. [Security & Biometrics](#17-security--biometrics)
18. [Help, Support & FAQs](#18-help-support--faqs)

---

## 2. PDF to Trend Curve & Excel Analyzer (Master Feature)

Trend Curve app me ab ek powerful **PDF Data Analyzer Engine** integrated hai jo kisi bhi PDF table se numbers aur dates extract karta hai, trend curves banata hai, aur automatically 4-sheet Excel (.xlsx) file create karke share karta hai.

### Navigation:
* **Bottom Navigation Bar:** Screen ke bottom me **"PDF Analyzer"** tab par tap karein.
* **Dashboard Banner:** Home dashboard ke top par **"Open PDF Analyzer"** button par tap karein.

### 5-Step Workflow:

#### Step 1: PDF Upload & Parsing
1. **Browse Device Storage:** Button dabakar apne phone ke internal storage ya downloads folder se koi bhi PDF select karein jisme tabular data ho.
2. **File Validation:** App check karta hai ki file valid PDF hai ya nahi. Empty ya corrupted PDF hone par turant clear warning aati hai.
3. **1-Tap Test Samples:** Agar aapke phone me turant koi tabular PDF available nahi hai, toh app me 2 ready-to-use sample datasets diye gaye hain:
   * **Sensor Telemetry:** Temperature, Pressure, aur Voltage ke sensor logs.
   * **Financial Metrics:** Monthly Revenue, Operating Margin, aur Units Sold ka financial performance table.
   In buttons ko dabate hi instantly PDF data parse ho jayega!
4. **Multiple Tables Detection:** Agar ek PDF file me 1 se zyada tables milti hain, toh dropdown se aap easily choose kar sakte hain ki kaunsi table analyze karni hai.

#### Step 2: Review Extracted Variables & X-Axis Configuration
1. **Automatic Type Detection:** Har ek column ka data type automatically detect hota hai:
   * **Numeric Badge (Blue):** Numbers, integers aur decimals.
   * **Date / Time Badge (Cyan):** Dates aur timestamps.
   * **Text Badge (Orange):** Textual strings ya category columns.
2. **Search Box:** Badi tables me column name search karke filter karein.
3. **Select All Numeric / Clear:** Ek click me sabhi eligible numeric columns select ya unselect karein.
4. **Reference X-Axis Selector:**
   * Agar table me date/time column hai toh app use automatically X-Axis ke roop me select karti hai.
   * User chahein toh manually kisi bhi date column ya default Row Index (1, 2, 3...) ko X-Axis bana sakte hain.
5. **Missing Values Handling Strategy:**
   * **Ignore:** Khali cells ko skip karta hai.
   * **Treat as 0:** Khali cells ko 0.0 value assign karta hai.
   * **Interpolate:** Previous aur next values ke beech mathematical linear interpolation karke curve ko smooth rakhta hai.

#### Step 3: Interactive Trend Curves (Visualization)
1. **Recharts-equivalent Native Charting:** `fl_chart` library ka use karke smooth curved bezier lines render hoti hain.
2. **Chart Modes:**
   * **Combined Mode:** Sabhi selected variables ek hi chart par alag-alag curated color curves me dikhte hain.
   * **Individual Mode:** Ek specific variable ko isolate karke detailed deep-dive curve dikhata hai.
3. **Touch Tooltip:** Chart par kisi bhi point par tap ya drag karne par exact Date/Index aur uski calculated numeric value ka tooltip popup aata hai.
4. **Interactive Legend:** Neeche diye gaye variable badges par tap karke instant focus switch kar sakte hain.

#### Step 4: Statistical Trend Summary
Har ek selected numeric variable ke liye mathematically verified metrics calculate hote hain:
* **Average (Mean):** Sabhi values ka mathematical average.
* **Median:** Midpoint observation value.
* **Min & Max:** Minimum aur maximum limits.
* **First & Last Value:** Timeline ki pehli aur aakhri values.
* **Difference & Percentage Change (%):** Overall growth ya drop percentage (Green / Red indicator).
* **Trend Direction Badge:**
  * 📈 **Increasing:** Positive upward growth.
  * 📉 **Decreasing:** Downward decline.
  * ➖ **Stable:** Balanced sideways trend.

#### Step 5: Data Table & Multi-Sheet Excel Export (.xlsx)
1. **Processed Data Table Preview:**
   * Table me horizontal scroll aur pagination (15 rows per page) supported hai.
   * Kisi bhi column header par tap karke Ascending/Descending sort karein.
   * "Selected Only" filter toggle karke sirf selected columns dekhein.
   * Search box se rows me search karein.
2. **Export to Excel (.xlsx):**
   * Prominent green button **"Export to Excel (.xlsx)"** dabayein.
   * App automatically real multi-sheet workbook generate karti hai:
     * **Sheet 1: Original Data:** PDF se extract hua complete raw data.
     * **Sheet 2: Selected Variables:** Sirf user ke dwara chune gaye variables.
     * **Sheet 3: Trend Data:** Reference X-Axis aur corresponding curve values.
     * **Sheet 4: Summary:** Sabhi statistical metrics (Min, Max, Avg, First, Last, Direction, Valid observations, Missing count).
   * File name standard format: `trend_analysis_YYYY-MM-DD_HH-mm.xlsx`.
   * File create hote hi Android ka native **Share Sheet** khulta hai jisse aap file ko directly Microsoft Excel, Google Sheets, WhatsApp, Gmail, ya Device Files me save kar sakte hain!

---

## 1. App Ka Main Maqsad (Purpose)

Trend Curve ek **Data Tracking & Growth Analytics** application hai. Iska use aap kisi bhi number-based metric ko time ke saath track karne aur uski growth/decline dekhne ke liye karte hain:
* **Business & Finance:** Monthly Revenue (₹), Expenses, Daily Sales, Profit Margin, Investment Value.
* **Health & Fitness:** Weight (kg), Daily Water Intake (Liters), Running Distance (km), Gym Workouts.
* **Productivity & Education:** Daily Study Hours, Coding Time, Books Read, Task Completion Rate.
* **Social Media & Tech:** YouTube Subscribers, Website Visitors, App Downloads, Active Users.

App aapke data ke basis par mathematical formulas run karke **Growth %**, **Direction (Growing/Declining/Stable)**, aur **Automated Insights** generate karti hai.

---

## 2. Splash & Onboarding Screens

### A. Splash Screen
* **Kya Dikhta Hai:** Trend Curve ka animated indigo-cyan logo, App Name, aur tagline *"Track. Analyze. Grow."*.
* **Kaise Kaam Karta Hai:** 1.5 seconds ke subtle scale & fade animation ke baad check karta hai ki aap pehli baar app khol rahe hain ya pehle se user hain.
  * *First launch par:* Onboarding screen par bhejta hai.
  * *Logged in hone par:* Seedhe Dashboard par bhejta hai.
  * *Logged out hone par:* Login screen par bhejta hai.

### B. Onboarding Screens (3 Slides)
Naye users ko app ka core concept samjhane ke liye 3 interactive slides hain:
1. **Slide 1 - "Track Your Trends":** Kisi bhi metric ko shuru karne ki jaankari.
2. **Slide 2 - "Understand Your Growth":** Interactive charts aur visual curves ki jaankari.
3. **Slide 3 - "Make Better Decisions":** Data se insights nikaal kar decision-making improve karne ka guide.

* **Buttons & Controls:**
  * **Skip (Top-Right):** Agar aap carousel padhna nahi chahte, toh direct Skip dabakar Login par ja sakte hain.
  * **Dots Indicator (Center-Bottom):** Batata hai ki aap kaunsi slide par hain.
  * **Next Button:** Agli slide par le jata hai.
  * **Get Started Button (Last Slide par):** Onboarding complete mark karta hai aur Login screen par le jata hai.

---

## 3. Authentication (Login, Register & Password Reset)

Trend Curve secure local session token manage karta hai aur future backend sync ke liye ready hai.

### A. Login Screen (`/login`)
* **Fields:**
  * `Email Address`: Valid email format (e.g. `alex@example.com`).
  * `Password`: Minimum 6 characters (eye icon par tap karke password show/hide kar sakte hain).
* **Controls & Buttons:**
  * **Remember Me Checkbox:** Toggle karke session save rakhein.
  * **Forgot password?:** Password reset flow open karta hai.
  * **Sign In Button:** Credentials validate karke user ko authenticate karta hai aur Dashboard par le jata hai.
  * **Google / Apple UI Buttons:** Social login interface buttons.
  * **"Don't have an account? Sign Up":** Register screen par bhejta hai.

### B. Register Screen (`/register`)
* **Fields:**
  * `Full Name`: User ka pura naam.
  * `Email Address`: Account email.
  * `Password`: Secret key (min 6 chars).
  * `Confirm Password`: Dono passwords match hone chahiye.
* **Button:** **"Create Account"** par tap karte hi naya user create hota hai, session token issue hota hai aur seedhe Dashboard khul jata hai.

### C. Password Reset Flow (3 Steps)
1. **Forgot Password Screen (`/forgot-password`):** Email daal kar **"Send Verification Code"** dabayein.
2. **OTP Verification Screen (`/otp-verification`):** 6-digit OTP code enter karein (Default offline test code: `123456`) aur **"Verify Code"** dabayein.
3. **Reset Password Screen (`/reset-password`):** Naya password aur confirm password enter karke **"Update Password"** karein. Password update hote hi wapas login screen khul jayegi.

---

## 4. Dashboard (Home Screen)

Dashboard app ka central command center hai jahan aapko aapke sabhi metrics ka instant snapshot milta hai.

### Header Controls:
* **Profile Monogram Avatar (Left):** Is par tap karne se aap seedhe **Profile Screen** par pahunch jate hain.
* **Greeting & Name:** Din ke time ke hisaab se dynamic greeting (Good morning / afternoon / evening) aur user ka naam show karta hai.
* **Search Icon (Magnifying Glass):** Tap karne se **Global Search Screen** khulti hai jahan sabhi trends, logs aur notes search ho sakte hain.
* **Notification Bell (Right):** Tap karne se Notifications screen khulti hai. Agar koi unread notification hai toh red dot badge dikhta hai.

### A. Overview Cards (Top Metric Tiles):
1. **Total Trends Card:** Aapke active trends ki total sankhya aur kitne trends grow kar rahe hain. (Tap karne par Trends tab khulta hai).
2. **Data Points Card:** Ab tak kitne total historical entries log kiye gaye hain.
3. **Average Growth Card:** Sabhi trends ka cumulative average percentage growth rate (+/- %).
4. **Best Performer Card:** Sabse zyada growth achieve karne wale trend ka naam aur value. (Tap karne par us trend ki Details Screen khulti hai).

### B. Overall Performance Chart (Main Interactive Graph):
* **Time Range Selector Pills:** **`7D`**, **`30D`**, **`3M`**, **`6M`**, **`1Y`**, **`All`**
  * In pills par tap karke aap chart ka timeframe switch kar sakte hain (e.g. pichle 7 din ka data ya pichle 1 saal ka data).
* **Interactive Line Curve:**
  * Finger se graph par touch/drag karein — touch karte hi exact Date aur Formatted Value ka popup tooltip aayega.
  * Below-curve smooth gradient shading visual depth deta hai.

### C. Quick Actions (Fast Buttons):
* **Create Trend (+ Icon):** Seedhe naya trend create karne ka form kholta hai.
* **Add Data (Timeline Icon):** Most active trend mein nayi entry log karne ka dialog kholta hai.
* **Compare (Arrows Icon):** Multiple trends ko ek hi chart par compare karne ki screen kholta hai.
* **View Analytics (Bar Chart Icon):** Dedicated Analytics tab par navigate karta hai.

### D. Recent Trends List:
* Top 3 active trends ke cards dikhte hain jisme har trend ka current value, growth badge, aur mini-sparkline curve hota hai.
* **"See All" Button:** Tap karne par full Trends Tab par le jata hai.

### E. Recent Activity Timeline:
* Aapke dwara kiye gaye recent updates ka log (e.g. "Added data point", "Created Gym trend").
* **"View All" Button:** Activity tab par le jata hai.

* **Pull-to-Refresh:** Screen ko niche kheench kar refresh karne se saara data locally re-sync ho jata hai.

---

## 5. Trends Management (Search, Filter, Sort & Cards)

Bottom bar ke second tab **"Trends"** par jakar aap apne saare metrics ko manage karte hain.

### Top App Bar Buttons:
1. **Search Icon:** Tap karne par search box open hota hai. Type karte hi list real-time filter hoti hai (Trend name, category, ya description ke basis par).
2. **Filter Icon (Funnel):** Tap karne par **Filter Bottom Sheet** khulti hai:
   * **Category Filter:** Business, Finance, Health, Productivity, Social, Education, Tech, Custom me se koi bhi category select karein.
   * **Trend Direction Filter:** Sirf **Positive (Growing)**, **Negative (Declining)**, ya **Stable** trends filter karein.
   * **Frequency Filter:** Daily, Weekly, Monthly, Yearly.
   * **Value Range Slider:** Min/Max numerical value ke hisaab se filter karein.
   * **Apply Filter Button:** Naye filter rules apply karta hai (Screen par active filter chips dikhne lagte hain jinhe `x` dabakar hata sakte hain).
   * **Reset Button:** Saare filters clear karta hai.
3. **Sort Icon (3 Lines):** Tap karne par Sort modal khulta hai:
   * *Recently Updated:* Sabse naye update wale upar.
   * *Name (A-Z):* Alphabetical order.
   * *Highest Growth:* Sabse zyada grow karne wale pehle.
   * *Lowest Growth:* Sabse kam grow karne wale pehle.
   * *Highest Value / Lowest Value:* Values ke ascending/descending order me.
4. **Floating Action Button ("+ New Trend"):** Bottom-right ka floating button jo naya trend create karne ki screen kholta hai.

### Trend Card Elements:
* **Category Icon & Color:** Trend ka custom color aur icon.
* **Trend Name & Category Badge:** Kaunsa metric hai.
* **Current Value vs Previous Value:** Current status.
* **Percentage Badge:** Green (+%) for growth, Red (-%) for decline, Grey for stable.
* **Mini Sparkline Graph:** Pichle data points ka miniature curve.
* **Card Tap Action:** Card par tap karte hi uski **Detailed Analytics Screen** khulti hai.

---

## 6. Naya Trend Create Karna (Create Trend Screen)

Jab aap **"+ New Trend"** ya Dashboard ke **"Create Trend"** par tap karte hain:

### Form Fields:
1. **Trend Name (Required):** Metric ka naam (e.g. `Monthly Revenue`, `Gym Attendance`, `Daily Reading`).
2. **Description (Optional):** Is trend ka context (e.g. `Tracking net income after expenses`).
3. **Category Chips:** Single-tap category selector (Business, Finance, Health, Productivity, Social, Education, Tech, Custom).
4. **Unit / Symbol (Required):** Metric ka symbol ya measurement unit (e.g. `₹`, `$`, `kg`, `hours`, `visitors`, `steps`, `%`).
5. **Initial Value:** Starting value (default `0`).
6. **Target Goal Value:** Aapka ultimate target (e.g. `100000`).
7. **Color Palette Selector:** 8 premium tailored colors (Electric Indigo, Cyan, Emerald Green, Amber, Crimson Red, Purple, Pink, Blue) me se apna theme color select karein.
8. **Start Date Picker:** Calendar icon par tap karke shuruat ki taareekh chunein.
9. **Tracking Frequency Dropdown:** Daily, Weekly, Monthly, Yearly.

* **Save Trend Button:** Tap karte hi input validate hota hai, naya trend database me save hota hai, activity log me add hota hai, aur app aapko **Trend Details Screen** par le aati hai.

---

## 7. Trend Details & Analytics Screen

Kisi bhi Trend Card par tap karne par ye deep analytics screen khulti hai.

### Top AppBar & More Options Menu (`⋮` Three Dots):
* **Edit Trend:** Trend ka naam, category, target, color ya frequency modify karein.
* **Duplicate:** Us trend ki duplicate copy bana deta hai (`Trend Name (Copy)`) jisme saare historical data points bhi clone ho jate hain.
* **Archive / Restore:** Agar aap kisi trend ko abhi track nahi kar rahe toh use Archive kar sakte hain (ye delete nahi hota, bas main view se hide ho jata hai aur restore kiya ja sakta hai).
* **Delete (Destructive):** Red color delete option. Tap karne par confirmation popup aata hai — confirm karne par trend permanently remove ho jata hai.

### Screen Sections:
1. **Top Value & Insight Banner:**
   * Current value badi typography me dikhti hai.
   * **Lightbulb Automated Insight:** Mathematical formula se auto-generated insight message (e.g. *"Your Monthly Revenue increased by 25.0% compared with the previous period."*).
2. **Performance Curve (Large Chart):**
   * Bada interactive line chart with tooltips.
   * Range selector: **`7D`**, **`30D`**, **`3M`**, **`6M`**, **`1Y`**, **`All`**.
3. **Calculated Statistics Grid (8 Metrics Cards):**
   * *Starting Value:* Pehli logged entry.
   * *Highest Point:* Ab tak ka maximum record (Green text).
   * *Lowest Point:* Ab tak ka minimum record (Red text).
   * *Average Value:* Saari entries ka arithmetic mean.
   * *Total Change:* Net numerical change (+ / -).
   * *Overall Growth:* Starting se current tak ka percentage jump.
   * *Best Spike Period:* Kaunse period me sabse bada spike aaya.
   * *Target Goal:* Set kiya gaya lakshya.
4. **Recorded Data Points Section:**
   * Saare data points ki list reverse chronological order me (latest entry upar).
   * Har entry me Date, Value, aur Optional Note dikhta hai.
   * **Edit Icon (Pencil):** Entry ko modify karne ka dialog kholta hai.
   * **Delete Icon (Trash):** Entry ko delete karne ka confirmation popup kholta hai. Delete hote hi chart aur calculations instantly update ho jate hain.
5. **Floating Action Button ("+ Add Point"):** Nayi entry log karne ka dialog kholta hai.

---

## 8. Data Points Add, Edit & Delete Karna

### Add Data Point Dialog:
* **Date Picker:** Calendar par tap karke jis din ka data log karna hai wo date select karein (past dates bhi select kar sakte hain).
* **Value Field:** Log ki jaane wali numerical value (e.g. `85000` ya `72.5`).
* **Note Field (Optional):** Entry ke baare me koi reminder ya reason (e.g. `Black Friday Sale bump` ya `Fever ke baad recovery`).
* **Buttons:**
  * **Cancel:** Dialog close karega bina save kiye.
  * **Save:** Save karte hi database update hoga, chart nayi curve draw karega, aur timeline activity record hogi.

### Edit Data Point Dialog:
* Agar purani value galat enter ho gayi ho, toh pencil icon tap karke Date, Value ya Note update karein aur **"Update"** dabayein.

### Delete Confirmation Dialog:
* Trash can icon dabane par safety prompt aayega: *"Delete this historical data entry?"*.
* **"Delete"** dabane par entry remove ho jayegi aur Trend ki current value previous point par automatically fall-back ho jayegi.

---

## 9. Dedicated Analytics & Multi-Trend Comparison

Bottom bar ke third tab **"Analytics"** par deep visual comparison tools hain.

### A. Comparison CTA Banner (Top):
* **"Compare Multi-Trend Curves" Card:** Isme **"Compare"** button par tap karke aap Multi-Trend comparison screen khol sakte hain.

### B. Overview Metrics:
* **Average Growth:** Sabhi metrics ki average growth rate.
* **Growing Trends:** Kitne trends positive hain aur unka percentage health score.
* **Declining Trends:** Kitne metrics negative me chal rahe hain aur dhyan dene ki zaroorat hai.
* **Stable Trends:** Kitne metrics flat/constant hain.

### C. Top & Bottom Performers:
* **Top Performing Card (Star Icon):** Sabse tez grow karne wala metric.
* **Needs Attention Card (Warning Icon):** Sabse zyada decline hone wala metric.

### D. Cumulative Volume by Category (Bar Chart):
* Bar chart jo show karta hai ki alag-alag categories (Business, Finance, Health, etc.) me kitna total numerical volume distribute hua hai.

### E. Compare Trends Screen (`/compare-trends`):
* **Multi-Selection Chips:** Upar diye gaye chips me se aap kisi bhi **2 ya 3 trends** ko simultaneously select kar sakte hain.
* **Combined Chart:** Teeno trends alag-alag colors (Indigo, Cyan, Violet, Amber) ki lines me ek hi graph par render hote hain.
* **Individual Metric Cards:** Har selected trend ka Current Value, Growth %, aur Category breakdown niche clear cards me compare hota hai.

---

## 10. Activity Timeline Log

Bottom bar ke fourth tab **"Activity"** par aapke dwara kiye gaye har action ka audit trail hota hai.

* **Search Field:** Activity log me specific text filter karein (e.g. search `Revenue` ya `Deleted`).
* **Timeline Tile Elements:**
  * Action icon (Add Chart, Trending Up, Delete, Timeline, etc.).
  * Action Title (e.g. *"Created 'Monthly Revenue' trend"*).
  * Description (e.g. *"Value logged: 75000 (Milestone bump)"*).
  * Timestamp (e.g. *"2 hours ago"*).
  * **Tap to Navigate:** Agar activity kisi trend se judi hai, toh tile par tap karte hi seedhe us trend ki Details Screen open ho jati hai.
* **Clear History Icon (Top-Right):** Agar aap timeline saaf karna chahte hain, toh trash icon se history clear kar sakte hain.

---

## 11. Notifications Center

Header ke Bell Icon par tap karne se notifications khulte hain:
* **Types of Notifications:**
  1. *Trend Milestone:* "Monthly Revenue hit all-time high!"
  2. *Goal Reached:* Target complete hone par alert.
  3. *Trend Decline:* Agar koi metric tezi se gir raha ho.
  4. *Data Reminder:* Naya data point log karne ka reminder.
* **Controls:**
  * **Unread Indicator:** Naye notifications par highlight dot rehti hai.
  * **Tap on Notification:** Unread status 'Read' mark ho jata hai aur related trend par navigate ho jata hai.
  * **Mark All as Read (Top-Right):** Ek tap me saari notifications read mark ho jati hain.
  * **Delete Notification (Cross/Trash):** Individual notification remove karne ke liye.

---

## 12. Global Search Feature

Header ke Magnifying Glass icon par tap karne se Global Search screen khulti hai:
* **Universal Search Bar:** Jaise hi aap type karna shuru karte hain:
  1. **Matched Trends:** Name, Category aur Description match hone wale trends show hote hain (Card tap karne par details khulti hai).
  2. **Matched Data Points:** Jin historical data points ke notes me wo shabd hoga wo filter hokar aate hain.
  3. **Matched Activities:** Timeline logs me matching actions show hote hain.
* **Clear Query Button (`x`):** Search query clear karne ke liye.

---

## 13. Profile & User Settings

Bottom bar ke fifth tab **"Profile"** par:

### User Profile Card:
* User ka Monogram Avatar, Display Name aur Email address.
* **Total Trends** aur **Total Data Points** ke summary counters.

### Menu Options:
1. **Edit Profile (`/account-settings`):** Apna Display Name aur Email update karein $\rightarrow$ **"Save Changes"** dabate hi poori app me naya naam update ho jata hai.
2. **Appearance (`/appearance`):** Theme change karne ke liye.
3. **Notifications (`/notifications`):** Alerts view karne ke liye.
4. **Security (`/security`):** Password update aur Biometrics toggle.
5. **All Settings & Preferences (`/settings`):** Advanced system settings.
6. **Help & Support (`/help-support`):** Support contact aur FAQs.
7. **About Trend Curve (`/about`):** Version info, framework details, aur architecture overview.
8. **Log Out Button (Red Text):** Tap karne par confirmation modal aata hai. Confirm karne par session token clear hota hai aur app safely `/login` screen par redirect ho jati hai.

---

## 14. Theme & Appearance (Dark Mode)

**Profile $\rightarrow$ Appearance** me jakar aap apni manpasand theme choose kar sakte hain:
* **Light Mode:** Ultra-clean Slate-50 background, high contrast dark text, bright white cards.
* **Dark Mode:** Deep Navy-Black (`#090D16`) sleek background, dark slate cards, neon indigo & cyan accent curves. (OLED friendly aur battery saving).
* **System Default:** Aapke phone ki system settings ke hisaab se din me Light aur raat me Dark automatically switch karega.

*Selection phone ki storage me instantly persist ho jati hai.*

---

## 15. Data Sovereignty (Backup Export & Import)

Trend Curve me aapka data kisi third-party server ke mohtaaj nahi hai. Aap jab chahein backup le sakte hain:

**Profile $\rightarrow$ Settings $\rightarrow$ DATA Section:**
1. **Export Data:**
   * Is par tap karte hi ek dialog open hota hai jisme do tabs hain:
     * **JSON Format:** Developer-friendly complete database dump.
     * **CSV Format:** Excel / Google Sheets me open karne layak tabular format (TrendID, Name, Category, Unit, Date, Value, Note).
   * **"Copy to Clipboard" Button:** Ek click me poora raw text clipboard par copy ho jata hai jise aap WhatsApp, email, ya notes me paste karke save rakh sakte hain.
2. **Import Data:**
   * Agar aapne pehle backup liya tha, toh raw JSON text paste karke **"Import"** dabayein — aapke purane saare trends restore ho jayenge.
3. **Clear Local Data:**
   * Testing ke baad agar aapko fresh start karna ho, toh saare trends delete karke clean empty state dekh sakte hain.
4. **Reset to Seed Data:**
   * Sample realistic trends (Monthly Revenue, Fitness, etc.) ko dobara restore karne ke liye.

---

## 16. Security & Biometrics

**Profile $\rightarrow$ Security:**
* **Biometric Unlock Switch:** Fingerprint / Face ID lock toggle karne ke liye.
* **Change Password Form:**
  * Current Password daalein.
  * New Password aur Confirm New Password daalein.
  * **"Update Password"** dabate hi naya credential save ho jata hai.

---

## 17. Help, Support & FAQs

**Profile $\rightarrow$ Help & Support:**
* **"Contact Support Team" Button:** In-app query trigger karne ke liye.
* **Accordion FAQs:**
  * *Percentage Growth formula:* `((Current - Previous) / Previous) * 100`.
  * *Custom Units:* Kaise ₹, $, kg, hours custom enter karein.
  * *Multi-Trend comparison:* Kaise 3 trends ek graph par layein.
  * *Data backup:* JSON/CSV export guide.

---

## 💡 Quick Tips For Best Experience

1. **Daily Tracking:** Har din ya week me ek baar apne Trend me **"+ Add Point"** dabakar latest value update karein taaki momentum curve accurate rahe.
2. **Multi-Curve Compare:** Business me `Revenue` aur `Expenses` ka alag trend banayein aur **Analytics $\rightarrow$ Compare** me dono ko ek saath dekhein taaki profit gap visible ho sake.
3. **Export Regularly:** Month-end par **Settings $\rightarrow$ Export Data** se CSV copy karke apne records me rakh lein.
