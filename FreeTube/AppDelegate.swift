import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Setup window (iOS 12 style - no SceneDelegate)
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Setup appearance
        setupAppearance()
        
        // Set root view controller
        let tabBarController = MainTabBarController()
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        return true
    }
    
    private func setupAppearance() {
        // Navigation bar
        UINavigationBar.appearance().barTintColor = UIColor(red: 0.1, green: 0.1, blue: 0.12, alpha: 1.0)
        UINavigationBar.appearance().tintColor = UIColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0)
        UINavigationBar.appearance().titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        UINavigationBar.appearance().isTranslucent = false
        
        if #available(iOS 13.0, *) {
            // Handled by system
        } else {
            UINavigationBar.appearance().barStyle = .black
        }
        
        // Tab bar
        UITabBar.appearance().barTintColor = UIColor(red: 0.08, green: 0.08, blue: 0.1, alpha: 1.0)
        UITabBar.appearance().tintColor = UIColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0)
        UITabBar.appearance().unselectedItemTintColor = UIColor(white: 0.5, alpha: 1.0)
        UITabBar.appearance().isTranslucent = false
    }
}
