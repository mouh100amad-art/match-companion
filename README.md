# رفيق المباريات — Match Companion

تطبيق أندرويد شخصي لمتابعة المباريات الرياضية، بجدول مباريات، إشعارات وتذكير قبل الانطلاق، مفضلة، ومشغل HLS يدعم SD/HD/FHD.

> **إخلاء مسؤولية قانوني مهم:** هذا التطبيق **لا يستضيف ولا يبث** أي محتوى مدفوع أو محمي بحقوق نشر. لا يحتوي على أي روابط بث لقنوات beIN Sports. دوره الوحيد هو عرض جدول المباريات، وتذكيرك بها، وفتح **المنصات الرسمية** (TOD / beIN CONNECT / FIFA+) في تطبيقاتها أو مواقعها. المشغل المخصص يعمل فقط على الروابط التي **تملك أنت حق استخدامها**. أنت مسؤول بالكامل عن أي رابط تستخدمه.

## الميزات

- جدول المباريات القادمة من TheSportsDB (مجاني) مع بيانات احتياطية مدمجة.
- واجهة عربية RTL بسيطة، Material 3، وضع فاتح/داكن.
- مفضلة (نجوم) محفوظة محلياً.
- تذكير قبل المباراة (5/10/15/30/60 دقيقة) عبر إشعارات محلية دقيقة.
- فتح TOD (رسمي) وbeIN CONNECT (رسمي) وFIFA+ وbeIN Sports News.
- مشغل HLS مخصص مع اكتشاف الجودات تلقائياً (SD / HD / FHD / 4K) وتبديلها دون فقدان موضع التشغيل.
- حماية: HTTPS فقط، منع cleartext، فحص الروابط، منع النسخ الاحتياطي، ProGuard/R8.

## الحصول على APK عبر GitHub Actions (الأسهل)

1. أنشئ مستودعاً جديداً على GitHub وارفع محتويات هذا المجلد.
2. افتح تبويب **Actions** ← اختر **Build Release APK** ← **Run workflow**.
3. بعد انتهاء البناء، نزّل الـ Artifact باسم `match-companion-apk`، بداخله `app-release.apk`.
4. انقل الـ APK إلى هاتفك وثبّته (فعّل "تثبيت التطبيقات من مصادر غير معروفة").

> الـ APK يُوقّع بمفتاح debug لأغراض الاستخدام الشخصي. للتوزيع العام أنشئ keystore خاصاً وعدّل `android/app/build.gradle`.

## البناء محلياً

```bash
flutter pub get
cd android && gradle wrapper --gradle-version 8.9 && cd ..
flutter build apk --release
```

الناتج: `build/app/outputs/flutter-apk/app-release.apk`

## البنية

- `lib/services/api_service.dart` — جلب المباريات + بيانات احتياطية.
- `lib/services/notification_service.dart` — الإشعارات والتذكير الدقيق.
- `lib/services/hls_quality_parser.dart` — تحليل master playlist واستخراج الجودات.
- `lib/services/stream_launcher.dart` — فتح المنصات الرسمية.
- `lib/screens/player_screen.dart` — مشغل HLS مع تبديل الجودة.
- `lib/utils/validators.dart` — فحص أمان الروابط.

## ملاحظات أمنية

- `android:usesCleartextTraffic="false"` + `network_security_config.xml`.
- لا يتم تحميل أي كود ديناميكي.
- لا تُستخدم WebView لفتح محتوى غير موثوق.
- `android:allowBackup="false"`.
- الصلاحيات: الإنترنت، الإشعارات، المنبهات الدقيقة، إعادة التشغيل.

</BDS:create_file>

<BDS:create_file fileName=".gitignore">

```gitignore
.dart_tool/
.packages
build/
.flutter-plugins
.flutter-plugins-dependencies
android/.gradle/
android/local.properties
android/key.properties
*.iml
.idea/
.DS_Store

