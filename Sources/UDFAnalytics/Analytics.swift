
import Foundation
import class AppTrackingTransparency.ATTrackingManager

#if canImport(UIKit)
import UIKit.UIApplication

public typealias PlatformApplication = UIApplication
public typealias PlatformLaunchOptions = [UIApplication.LaunchOptionsKey: Any]?
#else
import AppKit.NSApplication

public typealias PlatformApplication = NSApplication
public typealias PlatformLaunchOptions = Notification
#endif

public let kScreenViewEvent = "screen_view"
public let kScreenNameParam = "screen_name"
public let kScreenClassParam = "screen_class"

public protocol Screen {
    var name: String { get }
}

public protocol RevenueProduct {
    var params: [String: Any] { get }
}

public protocol Analytics<Event> {
    associatedtype Event

    func logEvent(_ event: Event)
    func logEvent(_ event: Event, with: [String: Any])
    func increment(property: String, by: Double)

    func setName(for screen: Screen, screenClass: String, with: [String: Any]?)
    func setUserProperties(_ userInfo: [String: Any], userId: String?)
    func logRevenue(productId: String, productTitle: String, productItem: RevenueProduct?, value: NSNumber, currency: String)

    func setupTracking(with status: ATTrackingManager.AuthorizationStatus)    
    func applicationDidBecomeActive()
    func applicationDidLaunchWithOptions(application: PlatformApplication, _ launchOptions: PlatformLaunchOptions)
}

public extension Analytics {
    func setName(for screen: Screen, screenClass: String) {
        setName(for: screen, screenClass: screenClass, with: nil)
    }
}
