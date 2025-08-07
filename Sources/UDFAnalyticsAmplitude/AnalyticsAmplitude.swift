
import Foundation
import UDF
import UDFAnalytics
import AmplitudeSwift
import class AppTrackingTransparency.ATTrackingManager

#if canImport(UIKit)
import UIKit.UIApplication
#else
import AppKit.NSApplication
#endif

public struct AnalyticsAmplitude<Event: RawRepresentable>: Analytics where Event.RawValue == String {

    private var amplitude: Amplitude

    public init(apiKey: String) {
        amplitude = .init(configuration: Configuration(apiKey: apiKey))
    }

    public init(configuration: Configuration) {
        amplitude = .init(configuration: configuration)
    }

    public func logEvent(_ event: Event) {
        amplitude.track(eventType: event.rawValue)
    }

    public func setName(for screen: Screen, screenClass: String, with: [String : Any]?) {
        var properties: [String: Any] = [
            kScreenNameParam: screen.name,
            kScreenClassParam: screenClass
        ]

        if let with {
            with.forEach { tuple in
                properties[tuple.key] = tuple.value
            }
        }

        amplitude.track(eventType: kScreenViewEvent, eventProperties: properties)
    }

    public func logEvent(_ event: Event, with: [String: Any]) {
        amplitude.track(eventType: event.rawValue, eventProperties: with)
    }

    public func setUserProperties(_ userInfo: [String: Any], userId: String?) {
        if let userId {
            amplitude.setUserId(userId: userId)
        }
        amplitude.identity.userProperties = userInfo
    }

    public func logRevenue(productId: String, productTitle: String, productItem: RevenueProduct?, value: NSNumber, currency: String) {
        let revenue = Revenue()
        revenue.productId = productId

        var params: [String: Any] = ["item_name": productTitle]
        if let productItem {
            params.merge(productItem.params) { current, _ in current }
        }

        revenue.properties = params
        revenue.price = value.doubleValue
        revenue.currency = currency

        amplitude.revenue(revenue: revenue)
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

    public func applicationDidLaunchWithOptions(application: PlatformApplication, _ launchOptions: PlatformLaunchOptions) {
        //do nothing
    }
}
