# ══════════════════════════════════════════════════════════════
#   قواعد R8 — أمواج
#
#   R8 يشيل أي كلاس ما يشوف أحد ينديه من الكود. بس كابستور
#   يلگي إضافاته **بالانعكاس** من أسمائها وقت التشغيل — يعني
#   R8 ما يشوف أي نداء إلها فيشيلها، والتطبيق ينهار بصمت.
#   فنكولّه صراحة: هذي لا تلمسها.
# ══════════════════════════════════════════════════════════════

# ── التعليقات التوضيحية: كابستور يقراها وقت التشغيل ──
-keepattributes *Annotation*, InnerClasses, Signature, Exceptions

# ── كابستور نفسه وكل إضافاته ──
-keep class com.getcapacitor.** { *; }
-keep @com.getcapacitor.annotation.CapacitorPlugin class * { *; }
-keep class * extends com.getcapacitor.Plugin { *; }
-keepclassmembers class * extends com.getcapacitor.Plugin {
  @com.getcapacitor.PluginMethod public <methods>;
}

# ── كوردوفا: كابستور يشغّل إضافاتها بنفس الأسلوب ──
-keep class org.apache.cordova.** { *; }
-dontwarn org.apache.cordova.**

# ── فايربيس والإشعارات ──
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# ── الجسر بين الويب فيو وجافا: الدوال تنندى بالاسم من الجافاسكربت ──
-keepclassmembers class * {
  @android.webkit.JavascriptInterface <methods>;
}

# ── نبقي أسماء الملفات وأرقام الأسطر، وإلا تقارير الأعطال بPlay
#    تجي مشفّرة وما نگدر نقراها ──
-keepattributes SourceFile, LineNumberTable
-renamesourcefileattribute SourceFile
