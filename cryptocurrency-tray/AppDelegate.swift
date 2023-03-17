import Cocoa
import SwiftUI

struct RespPrice: Codable {
    let price: Double
}
struct Resp: Codable {
    let bitcoin: RespPrice
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var popover: NSPopover!
    var statusBarItem: NSStatusItem!
    var timer: Timer!
    
    @objc func onButtonClick(sender: AnyObject?) {
        print("status bar clicked")
    }
    
    func setTitle(d: Double) {
        DispatchQueue.main.async {
            
            if let button = self.statusBarItem.button {
                let currencyFormatter = NumberFormatter()
                currencyFormatter.usesGroupingSeparator = true
                currencyFormatter.numberStyle = .currency
                currencyFormatter.locale = Locale(identifier: "en_US")
                let priceString = currencyFormatter.string(from: NSNumber(value: d))!
                button.image = NSImage(named: "btc")
                button.image?.size = NSSize(width: 16, height: 16)
                button.imagePosition = NSControl.ImagePosition.imageLeft
                button.title = priceString
            }
        }
    }
    @objc func didTapOne() {
        print("ONE")
        
        let url = URL(string: "https://coinmarketcap.com")!
        if NSWorkspace.shared.open(url) {
            print("default browser was successfully opened")
        }
    }
    func getData(){
        let url = URL(string: "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd")! //change the url
        let session = URLSession.shared
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request as URLRequest, completionHandler: { [self] data, response, error in
            
            guard error == nil else {
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                let bitcoinData = json?["bitcoin"] as? [String: Double]
                if let price = bitcoinData?["usd"] {
                    self.setTitle(d: price)
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        
        task.resume()
    }
    func setupMenus() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        self.statusBarItem.menu = menu
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApp.setActivationPolicy(.prohibited)
        self.timer = Timer()
        self.timer = Timer.scheduledTimer(withTimeInterval: 60*5, repeats: true, block: { _ in
            self.getData()
        })
        
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        setupMenus()
        if self.statusBarItem.button != nil {
            self.setTitle(d: 0)
            self.getData()
        }
    }
    
}
