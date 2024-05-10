
import Foundation
import UDF
import UDFAnalytics
import FirebaseAnalytics
import FirebaseCrashlytics
import FirebaseCore
import class AppTrackingTransparency.ATTrackingManager

private typealias FAnalytics = FirebaseAnalytics.Analytics

public struct AnalyticsFirebase<AnalyticsEvent: RawRepresentable>: UDFAnalytics.Analytics where AnalyticsEvent.RawValue == String {

    public init() {
        if !ProcessInfo.processInfo.xcTest {
            let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")!
            let options = FirebaseOptions(contentsOfFile: filePath)
            FirebaseApp.configure(options: options!)
        }
    }

    public func logEvent(_ event: AnalyticsEvent) {
        FAnalytics.logEvent(event.rawValue, parameters: nil)
    }

    public func setName(for screen: Screen, screenClass: String) {
        let params = [
            AnalyticsParameterScreenName: screen.name,
            AnalyticsParameterScreenClass: screenClass
        ]

        FAnalytics.logEvent(AnalyticsEventScreenView, parameters: params)
    }

    public func logEvent(_ event: AnalyticsEvent, with: [String : Any]) {
        FAnalytics.logEvent(event.rawValue, parameters: with)
    }

    public func setUserProperties(_ userInfo: [String : Any], userId: Int) {
        FAnalytics.setUserID(String(userId))
        Crashlytics.crashlytics().setUserID(String(userId))

        userInfo.forEach { key, value in
            FAnalytics.setUserProperty("\(value)", forName: key)
        }
    }

    public func logRevenue(productId: String, productTitle: String, productItem: RevenueProduct?, value: NSNumber, currency: String) {
        let item: [String : Any] = [
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
        //do nothing
    }
}
