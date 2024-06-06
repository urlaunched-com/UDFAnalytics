
import Foundation
import UDF
import class AppTrackingTransparency.ATTrackingManager
import class UIKit.UIApplication

public struct AnalyticsComposite<Event>: Reducible, Analytics {
    private var components: [any Analytics]

    public init() {
        components = []
    }

    public mutating func addComponent<T: Analytics>(_ component: T) where T.Event == Event {
        components.append(component)
    }

    public func reduce(_ action: some Action) {
        switch action {
            //TODO: Add after release UDF v1.4.5
//        case is Actions.ApplicationDidBecomeActive:
//            composite.applicationDidBecomeActive()
//
//        case let action as Actions.ApplicationDidLaunchWithOptions:
//            composite.applicationDidLaunchWithOptions(application: action.application, action.launchOptions)
//
//        case let action as Actions.DidUpdateATTrackingStatus:
//            composite.setupTracking(with: action.status)

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
        components.forEach {
            _logEvent(event, to: $0)
        }
    }

    func _logEvent<T: Analytics, Event>(_ event: Event, to component: T) {
        component.logEvent(event as! T.Event)
    }

    func logEvent(_ event: Event, with: [String: Any]) {
        components.forEach {
            _logEvent(event, to: $0, with: with)
        }
    }

    func _logEvent<T: Analytics, Event>(_ event: Event, to component: T, with: [String: Any]) {
        component.logEvent(event as! T.Event, with: with)
    }

    func increment(property: String, by: Double) {
        components.forEach { $0.increment(property: property, by: by) }
    }

    func setName(for screen: Screen, screenClass: String) {
        components.forEach { $0.setName(for: screen, screenClass: screenClass)}
    }

    func setUserProperties(_ userInfo: [String: Any], userId: Int?) {
        components.forEach { $0.setUserProperties(userInfo, userId: userId) }
    }

    func logRevenue(productId: String, productTitle: String, productItem: RevenueProduct?, value: NSNumber, currency: String) {
        components.forEach {
            $0.logRevenue(productId: productId, productTitle: productTitle, productItem: productItem, value: value, currency: currency)
        }
    }

    //TODO: Will be deprecated after the release of UDF v1.4.5
    func setupTracking(with status: ATTrackingManager.AuthorizationStatus) {
        components.forEach { $0.setupTracking(with: status) }
    }

    //TODO: Will be deprecated after the release of UDF v1.4.5
    func applicationDidBecomeActive() {
        components.forEach { $0.applicationDidBecomeActive() }
    }

    //TODO: Will be deprecated after the release of UDF v1.4.5
    func applicationDidLaunchWithOptions(
        application: UIApplication,
        _ launchOptions: [UIApplication.LaunchOptionsKey : Any]?
    ) {
        components.forEach { $0.applicationDidLaunchWithOptions(application: application, launchOptions) }
    }
}
