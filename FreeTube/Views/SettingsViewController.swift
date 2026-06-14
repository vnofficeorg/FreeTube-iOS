import UIKit

class SettingsViewController: UITableViewController {
    
    private let instances = InvidiousInstance.defaultInstances
    private var selectedIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Cài đặt"
        
        tableView.backgroundColor = UIColor(red: 0.08, green: 0.08, blue: 0.1, alpha: 1.0)
        tableView.separatorColor = UIColor(white: 0.2, alpha: 1.0)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // Find current instance
        let current = InvidiousAPI.shared.currentInstanceURL
        selectedIndex = instances.firstIndex(where: { $0.url == current }) ?? 0
    }
    
    // MARK: - Sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return instances.count  // Instance picker
        case 1: return 2               // Cache & History
        case 2: return 1               // About
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Chọn Invidious Instance"
        case 1: return "Dữ liệu"
        case 2: return "Thông tin"
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = UIColor(red: 1.0, green: 0.27, blue: 0.27, alpha: 1.0)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = UIColor(red: 0.12, green: 0.12, blue: 0.14, alpha: 1.0)
        cell.textLabel?.textColor = .white
        cell.selectionStyle = .none
        
        switch indexPath.section {
        case 0:
            let instance = instances[indexPath.row]
            cell.textLabel?.text = "\(instance.name)  [\(instance.region ?? "")]"
            cell.accessoryType = indexPath.row == selectedIndex ? .checkmark : .none
            cell.tintColor = UIColor(red: 1.0, green: 0.27, blue: 0.27, alpha: 1.0)
            
        case 1:
            if indexPath.row == 0 {
                cell.textLabel?.text = "🗑 Xóa cache ảnh"
                cell.textLabel?.textColor = UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)
            } else {
                cell.textLabel?.text = "🗑 Xóa lịch sử xem"
                cell.textLabel?.textColor = UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0)
            }
            
        case 2:
            cell.textLabel?.text = "FreeTube iOS v1.0 — iPad Air 1 Edition"
            cell.textLabel?.textColor = UIColor(white: 0.5, alpha: 1.0)
            cell.textLabel?.font = UIFont.systemFont(ofSize: 13)
            
        default:
            break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            selectedIndex = indexPath.row
            InvidiousAPI.shared.currentInstanceURL = instances[indexPath.row].url
            tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            
            // Show confirmation
            let alert = UIAlertController(
                title: "Đã chuyển",
                message: "Instance: \(instances[indexPath.row].name)",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            
        case 1:
            if indexPath.row == 0 {
                ImageCache.shared.clearCache()
                showAlert(title: "Đã xóa", message: "Cache ảnh đã được xóa")
            } else {
                let alert = UIAlertController(title: "Xóa lịch sử", message: "Bạn có chắc?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Hủy", style: .cancel))
                alert.addAction(UIAlertAction(title: "Xóa", style: .destructive) { _ in
                    HistoryManager.shared.clearHistory()
                    self.showAlert(title: "Đã xóa", message: "Lịch sử xem đã được xóa")
                })
                present(alert, animated: true)
            }
            
        default:
            break
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
