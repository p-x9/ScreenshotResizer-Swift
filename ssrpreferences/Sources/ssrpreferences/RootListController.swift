import Preferences
import ssrpreferencesC

class RootListController: PSListController {
    
    static let PREF_PATH  = "/var/mobile/Library/Preferences/com.p-x9.screenshotresizer.pref.plist"
    static let NOTIFY = "com.p-x9.screenshotresizer.prefschanged"
    
    override var specifiers: NSMutableArray? {
        get {
            var specifiers = value(forKey: "_specifiers") as? NSMutableArray
            if specifiers == nil {
                specifiers = loadSpecifiers(fromPlistName: "Root", target: self)
                setValue(specifiers, forKey: "_specifiers")
            }
            specifiers?.forEach { spec in
                guard let spec = spec as? PSSpecifier else { return }
                spec.setProperty(RootListController.NOTIFY, forKey: "PostNotification")
            }
            return specifiers
        }
        set {
            super.specifiers = newValue
        }
    }
    
    override func setPreferenceValue(_ value: Any!, specifier: PSSpecifier!) {
        let prefs = NSMutableDictionary(contentsOfFile: Self.PREF_PATH) ?? .init()
        prefs.setObject(value as Any, forKey: specifier.properties.object(forKey: "key") as! NSCopying)
        prefs.write(toFile: Self.PREF_PATH, atomically: true)
        
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
                                             CFNotificationName(rawValue: Self.NOTIFY as CFString),
                                             nil, nil, true)
    }
    
    @objc
    func twitter() {
        UIApplication.shared.open(URL(string: "https://mobile.twitter.com/p_x9")!)
    }
}
