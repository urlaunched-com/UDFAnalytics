
import Foundation
import class AppTrackingTransparency.ATTrackingManager
import class UIKit.UIApplication

public let kScreenViewEvent = "screen_view"
public let kScreenNameParam = "screen_name"
public let kScreenClassParam = "screen_class"

public protocol Screen {
    var name: String { get }
}

public protocol RevenueProduct {
    var params: [String: Any] { get }
}

public protocol Analytics {
    associatedtype Event

    func logEvent(_ event: Event)
    func logEvent(_ event: Event, with: [String: Any])
    func increment(property: String, by: Double)

    func setName(for screen: Screen, screenClass: String, with: [String: Any]?)
    func setUserProperties(_ userInfo: [String: Any], userId: Int)
    func logRevenue(productId: String, productTitle: String, productItem: RevenueProduct?, value: NSNumber, currency: String)

    func setupTracking(with status: ATTrackingManager.AuthorizationStatus)
    func applicationDidBecomeActive()
    func applicationDidLaunchWithOptions(
        application: UIApplication,
        _ launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    )
}
