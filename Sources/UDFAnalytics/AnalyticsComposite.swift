
import Foundation
import UDF
import class AppTrackingTransparency.ATTrackingManager
import class UIKit.UIApplication

public struct AnalyticsComposite<Event>: Reducible, Analytics {
    private var components: [any Analytics<Event>]

    public init(components: [any Analytics<Event>]) {
        self.components = components
    }

    public init() {
        components = []
    }

    public mutating func addComponent(_ component: some Analytics<Event>) {
        components.append(component)
    }

    public func reduce(_ action: some Action) {
        switch action {
        case is Actions.ApplicationDidBecomeActive:
            components.forEach { $0.applicationDidBecomeActive() }

        case let action as Actions.ApplicationDidLaunchWithOptions:
            components.forEach { $0.applicationDidLaunchWithOptions(application: action.application, action.launchOptions) }

        case let action as Actions.DidUpdateATTrackingStatus:
            components.forEach { $0.setupTracking(with: action.status) }

        default:
            break
        }
    }

    public static func == (lhs: AnalyticsComposite, rhs: AnalyticsComposite) -> Bool {
        true
    }
}

// MARK: - Analytics
public extension AnalyticsComposite {

    func logEvent(_ event: Event) {
        components.forEach { $0.logEvent(event) }
    }

    func logEvent(_ event: Event, with: [String: Any]) {
        components.forEach { $0.logEvent(event, with: with) }
    }

    func increment(property: String, by: Double) {
        components.forEach { $0.increment(property: property, by: by) }
    }

    func setName(for screen: Screen, screenClass: String, with: [String : Any]?) {
        components.forEach { $0.setName(for: screen, screenClass: screenClass, with: with) }
    }

    func setUserProperties(_ userInfo: [String: Any], userId: Int?) {
        components.forEach { $0.setUserProperties(userInfo, userId: userId) }
    }

    func logRevenue(productId: String, productTitle: String, productItem: RevenueProduct?, value: NSNumber, currency: String) {
        components.forEach {
            $0.logRevenue(productId: productId, productTitle: productTitle, productItem: productItem, value: value, currency: currency)
        }
    }

    func setupTracking(with status: ATTrackingManager.AuthorizationStatus) {
        fatalError("use Actions.DidUpdateATTrackingStatus instead of calling the setupTracking func directly")
    }

    func applicationDidBecomeActive() {
        fatalError("use Actions.ApplicationDidBecomeActive instead of calling the applicationDidBecomeActive func directly")
    }

    func applicationDidLaunchWithOptions(
        application: UIApplication,
        _ launchOptions: [UIApplication.LaunchOptionsKey : Any]?
    ) {
        fatalError("use Actions.ApplicationDidLaunchWithOptions instead of calling the applicationDidLaunchWithOptions func directly")
    }
}
