
import Foundation
import UDF
import UDFAnalytics
import Amplitude
import class AppTrackingTransparency.ATTrackingManager

#if canImport(UIKit)
import UIKit.UIApplication
#else
import AppKit.NSApplication
#endif

public struct AnalyticsAmplitude<Event: RawRepresentable>: Analytics where Event.RawValue == String {

    private var amplitude: Amplitude { .instance() }

    public init(apiKey: String, tracking: (inout AMPDefaultTrackingOptions) -> Void = { _ in }) {
        tracking(&amplitude.defaultTracking)
        amplitude.initializeApiKey(apiKey)
        amplitude.logEvent("app_start")
    }

    public func logEvent(_ event: Event) {
        amplitude.logEvent(event.rawValue)
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

        amplitude.logEvent(kScreenViewEvent, withEventProperties: properties)
    }

    public func logEvent(_ event: Event, with: [String: Any]) {
        amplitude.logEvent(event.rawValue, withEventProperties: with)
    }

    public func setUserProperties(_ userInfo: [String: Any], userId: String?) {
        if let userId {
            amplitude.setUserId(userId)
        }
        amplitude.setUserProperties(userInfo)
    }

    public func logRevenue(productId: String, productTitle: String, productItem: RevenueProduct?, value: NSNumber, currency: String) {
        let revenue = AMPRevenue()
        revenue.setProductIdentifier(productId)
        var params: [String: Any] = ["item_name": productTitle, "currency": currency]
        if let productItem {
            params.merge(productItem.params) { current, _ in current }
        }
        
        revenue.setEventProperties(params)
        revenue.setPrice(value)
        amplitude.logRevenueV2(revenue)
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
