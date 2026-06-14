import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupAppearance()
    }
    
    private func setupTabs() {
        let homeVC = HomeViewController()
        let homeNav = UINavigationController(rootViewController: homeVC)
        homeNav.tabBarItem = UITabBarItem(title: "Trang chủ", image: UIImage(named: "home_icon") ?? makeIcon("🏠"), tag: 0)
        
        let searchVC = SearchViewController()
        let searchNav = UINavigationController(rootViewController: searchVC)
        searchNav.tabBarItem = UITabBarItem(title: "Tìm kiếm", image: UIImage(named: "search_icon") ?? makeIcon("🔍"), tag: 1)
        
        let historyVC = HistoryViewController()
        let historyNav = UINavigationController(rootViewController: historyVC)
        historyNav.tabBarItem = UITabBarItem(title: "Lịch sử", image: UIImage(named: "history_icon") ?? makeIcon("🕐"), tag: 2)
        
        let settingsVC = SettingsViewController()
        let settingsNav = UINavigationController(rootViewController: settingsVC)
        settingsNav.tabBarItem = UITabBarItem(title: "Cài đặt", image: UIImage(named: "settings_icon") ?? makeIcon("⚙️"), tag: 3)
        
        viewControllers = [homeNav, searchNav, historyNav, settingsNav]
    }
    
    private func setupAppearance() {
        tabBar.barTintColor = UIColor(red: 0.08, green: 0.08, blue: 0.1, alpha: 1.0)
        tabBar.tintColor = UIColor(red: 1.0, green: 0.27, blue: 0.27, alpha: 1.0)
        tabBar.unselectedItemTintColor = UIColor(white: 0.45, alpha: 1.0)
        tabBar.isTranslucent = false
    }
    
    /// Create a simple icon from emoji for fallback
    private func makeIcon(_ emoji: String) -> UIImage? {
        let size = CGSize(width: 25, height: 25)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let rect = CGRect(origin: .zero, size: size)
        (emoji as NSString).draw(in: rect, withAttributes: [
            .font: UIFont.systemFont(ofSize: 20)
        ])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image?.withRenderingMode(.alwaysOriginal)
    }
}
