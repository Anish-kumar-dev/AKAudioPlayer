AKAudioPlayer
===============
AKAudioPlayer uses AVAudioPlayer from AVFoundation

Background Support
------------------

paste in AppDelegate

override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        becomeFirstResponder()
        return true
    }
