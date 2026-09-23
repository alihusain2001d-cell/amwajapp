import UIKit
import Capacitor
import WebKit   // allowsBackForwardNavigationGestures تحت

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // 🔔 الإشعارات — أبل تعطي رقم الجهاز هنا، ونسلّمه لإضافة كاباسيتور.
    //    بدون هاتين الدالتين حدث 'registration' بالتطبيق ما ينطلق أبداً،
    //    والإضافة ترمي «capacitorDidRegisterForRemoteNotifications not called».
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NotificationCenter.default.post(name: .capacitorDidRegisterForRemoteNotifications, object: deviceToken)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NotificationCenter.default.post(name: .capacitorDidFailToRegisterForRemoteNotifications, object: error)
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        // Called when the app was launched with a url. Feel free to add additional processing here,
        // but if you want the App API to support tracking app url opens, make sure to keep this call
        return ApplicationDelegateProxy.shared.application(app, open: url, options: options)
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        // Called when the app was launched with an activity, including Universal Links.
        // Feel free to add additional processing here, but if you want the App API to support
        // tracking app url opens, make sure to keep this call
        return ApplicationDelegateProxy.shared.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }

}

/* 🔙 سحبة الرجوع — من حافة الشاشة **اليمين** (التطبيق عربي).

   ⚠️ ما نستعمل سحبة الويب فيو الجاهزة (allowsBackForwardNavigationGestures)
      وجرّبناها أول مرة وطلعت غلط بشغلتين:
        • تشتغل من اليسار — ما تعرف إن التطبيق عربي
        • وقت السحب تعرض **صورة محفوظة** للصفحة السابقة، وهاي عندنا
          الرئيسية (خطوة التاريخ وحدة لكل النوافذ المفتوحة). فمن داخل
          شاشات براند تطلع الرئيسية، الجهاز يصفن، وبعدين تبين الماركات.
      السحبة الجاهزة مصمّمة لمواقع كل صفحة بيها رابط، مو لتطبيق نوافذ.

   بدالها سحبة خاصة: لما تخلص، ننادي history.back() — نفس الي يسويه
   زر الرجوع بالأندرويد. الصفحة (_navEnsure / popstate بالـindex.html)
   تسكّر آخر نافذة بحركتها الطبيعية. بالرئيسية ماكو خطوة بالتاريخ،
   فالسحبة ما تسوي شي — ما تطلّعك.

   مكتوبة بنفس ملف AppDelegate عمداً: ملف swift جديد لازم ينسجّل
   بملف المشروع project.pbxproj بيد، وهذا يلخبط بسهولة. وتنربط
   بالشاشة من Main.storyboard (customClass = AmwajViewController). */
class AmwajViewController: CAPBridgeViewController {
    override func capacitorDidLoad() {
        super.capacitorDidLoad()
        guard let wv = webView else { return }
        wv.allowsBackForwardNavigationGestures = false

        let edge = UIScreenEdgePanGestureRecognizer(target: self,
                                                    action: #selector(amwajEdgeBack(_:)))
        edge.edges = .right
        wv.addGestureRecognizer(edge)
        // التمرير ينتظر السحبة تفشل أول — بدونها لمسة الحافة تروح للتمرير
        wv.scrollView.panGestureRecognizer.require(toFail: edge)
    }

    @objc private func amwajEdgeBack(_ g: UIScreenEdgePanGestureRecognizer) {
        guard g.state == .ended, let v = g.view else { return }
        // من اليمين لليسار = موجب. تنحسب رجعة إذا سحب مسافة كافية أو بسرعة
        let dx = -g.translation(in: v).x
        let vx = -g.velocity(in: v).x
        if dx > 60 || vx > 500 {
            webView?.evaluateJavaScript("history.back()", completionHandler: nil)
        }
    }
}
