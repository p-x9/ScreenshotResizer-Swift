import Orion
import ScreenShotResizerC
import UIKit
import IOSurface
import VideoToolbox

struct localSettings {
    static var isTweakEnabled = true
    static var scale: CGFloat = 0.5
}

struct tweak: HookGroup {}


class SSMainScreenSnapshotter_Hook: ClassHook<SSMainScreenSnapshotter> {
    func takeScreenshot() -> UIImage {
        let image = orig.takeScreenshot()
        
        guard localSettings.isTweakEnabled else {
            return image
        }
        
        let ioSurface = image.perform(Selector(("ioSurface"))).takeUnretainedValue() as! IOSurface

        let pixelBufferAttributes = [
            kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_32BGRA
        ] as CFDictionary

        var pixelBuffer: Unmanaged<CVPixelBuffer>?
        CVPixelBufferCreateWithIOSurface(nil, ioSurface, pixelBufferAttributes, &pixelBuffer)

        guard let pixelBuffer = pixelBuffer else {
            return image
        }

        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer.takeUnretainedValue(), options: nil, imageOut: &cgImage)

        guard let cgImage = cgImage else {
            return image
        }

        return UIImage(cgImage: cgImage).resize(max(localSettings.scale, 0.0001))
    }
}

func readPrefs() {
    let path = "/var/mobile/Library/Preferences/com.p-x9.screenshotresizer.pref.plist"
    
    if !FileManager().fileExists(atPath: path) {
        try? FileManager().copyItem(atPath: "Library/PreferenceBundles/notchbanners.bundle/defaults.plist", toPath: path)
    }
    
    guard let dict = NSDictionary(contentsOfFile: path) else {
        return
    }
    
    //Reading values
    localSettings.isTweakEnabled = dict.value(forKey: "isEnabled") as? Bool ?? true
    localSettings.scale = dict.value(forKey: "scale") as? CGFloat ?? 0.5
}

func settingChanged() {
    readPrefs()
}

func observePrefsChange() {
    let NOTIFY = "com.p-x9.screenshotresizer.prefschanged" as CFString
    
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    nil, { _, _, _, _, _ in
        settingChanged()
    }, NOTIFY, nil, CFNotificationSuspensionBehavior.deliverImmediately)
}

struct ScreenshotResizer: Tweak {
    init() {
        readPrefs()
        observePrefsChange()
        tweak().activate()
    }
}
