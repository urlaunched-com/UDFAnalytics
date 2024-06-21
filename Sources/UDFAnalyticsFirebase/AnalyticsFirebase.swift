
import Foundation
import UDF
import UDFAnalytics
import FirebaseAnalytics
import FirebaseCrashlytics
import FirebaseCore
import class AppTrackingTransparency.ATTrackingManager

private typealias FAnalytics = FirebaseAnalytics.Analytics

public struct AnalyticsFirebase<Event: RawRepresentable>: UDFAnalytics.Analytics where Event.RawValue == String {

    public init() {}

    public func logEvent(_ event: Event) {
        FAnalytics.logEvent(event.rawValue, parameters: nil)
    }

    public func setName(for screen: Screen, screenClass: String, with: [String : Any]?) {
        var properties: [String: Any] = [
            AnalyticsParameterScreenName: screen.name,
            AnalyticsParameterScreenClass: screenClass
        ]

        if let with {
            with.forEach { tuple in
                properties[tuple.key] = tuple.value
            }
        }

        FAnalytics.logEvent(AnalyticsEventScreenView, parameters: properties)
    }

    public func logEvent(_ event: Event, with: [String: Any]) {
        FAnalytics.logEvent(event.rawValue, parameters: with)
    }

    public func setUserProperties(_ userInfo: [String: Any], userId: Int?) {
        if let userId {
            FAnalytics.setUserID(String(userId))
            Crashlytics.crashlytics().setUserID(String(userId))
        }

        userInfo.forEach { key, value in
            FAnalytics.setUserProperty("\(value)", forName: key)
        }
    }

    public func logRevenue(productId: String, productTitle: String, productItem: RevenueProduct?, value: NSNumber, currency: String) {
        let item: [String: Any] = [
            AnalyticsParameterItemID: productId,
            AnalyticsParameterItemName: productTitle
        ]

        var parameters: [String: Any] = [
            AnalyticsParameterValue: value,
            AnalyticsParameterCurrency: currency,
            AnalyticsParameterItems: [item]
        ]

        if let productItem {
            productItem.params.forEach { tuple in
                parameters[tuple.key] = tuple.value
            }
        }

        FAnalytics.logEvent(AnalyticsEventPurchase, parameters: parameters)
    }

    public func increment(property: String, by: Double) {
        //do nothing
    }

    public func setupTracking(with status: ATTrackingManager.AuthorizationStatus) {
        //do nothing
    }

    public func applicationDidBecomeActive() {
        //do nothing
    }

    public func applicationDidLaunchWithOptions(
        application: UIApplication,
        _ launchOptions: [UIApplication.LaunchOptionsKey : Any]?
    ) {
        guard !ProcessInfo.processInfo.xcTest else { return }
        
        DispatchQueue.main.async {
            if FirebaseApp.app() == nil {
                if let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
                   let options = FirebaseOptions(contentsOfFile: filePath) {
                    FirebaseApp.configure(options: options)
                } else {
                    FirebaseApp.configure()
                }
            }
        }
    }
}
