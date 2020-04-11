import UIKit
import ServiceChat
import ServiceCore


class ViewController: UIViewController {
    
    private struct Constants {
        static let liveAgentHostName = "<#live-agent-host-name#>"
        static let organisationId = "<#organisation-id#>"
        static let deploymentId = "<#deployment-id#>"
        static let buttonId = "<#button-id#>"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //swizzleLocalizedStringsSelectors()
    }

    @IBAction func didPressShowChatButton() {
        showChat()
    }
    
    private func showChat() {
        let config = SCSChatConfiguration(
            liveAgentPod: Constants.liveAgentHostName,
            orgId: Constants.organisationId,
            deploymentId: Constants.deploymentId,
            buttonId: Constants.buttonId
        )
        
        ServiceCloud.shared().chatUI.showChat(with: config!)
    }
    
    
    private func swizzleLocalizedStringsSelectors() {
        let originalSelector = NSSelectorFromString("overridableLocalizedStringForKey:table:bundleIdentifier:")
        let swizzledSeelctor = #selector(NSString.swizzledLocalizedString(forKey:table:bundleIdentifier:))
        
        do {
            try NSString.swizzleClass(selector: originalSelector, newSelector: swizzledSeelctor)
        } catch {
            print(error)
        }
    }
    
}

extension NSString {
    @objc class func swizzledLocalizedString(forKey key: NSString,
                                             table: NSString,
                                             bundleIdentifier: NSString) -> NSString {
        
        let bundle = Bundle(identifier: bundleIdentifier as String)!
        let localizedString = bundle.localizedString(forKey: key as String,
                                                     value: nil,
                                                     table: table as String)
        
        return NSString(string: localizedString)
    }
}

extension NSObject {
    class func swizzleClass(selector: Selector, newSelector: Selector) throws {
        let originalMethod = class_getClassMethod(self, selector)
        let swizzledMethod = class_getClassMethod(self, newSelector)
        
        guard let method = originalMethod, let newMethod = swizzledMethod else {
            preconditionFailure("Method not found")
        }
        
        method_exchangeImplementations(method, newMethod)
    }
}
