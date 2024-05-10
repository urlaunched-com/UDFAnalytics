
import Foundation
import UDF
import UDFAnalytics
import class AppTrackingTransparency.ATTrackingManager
import class UIKit.UIApplication
import Mixpanel

public struct AnalyticsMixpanel<AnalyticsEvent: RawRepresentable>: UDFAnalytics.Analytics where AnalyticsEvent.RawValue == String {
    public let token: String
    public let trackAutomaticEvents: Bool
    public let optOutTrackingByDefault: Bool

    private var mixpanel: MixpanelInstance { Mixpanel.mainInstance() }

    public init(token: String, trackAutomaticEvents: Bool = false, optOutTrackingByDefault: Bool = true) {
        self.token = token
        self.trackAutomaticEvents = trackAutomaticEvents
        self.optOutTrackingByDefault = optOutTrackingByDefault
    }

    public func logEvent(_ event: AnalyticsEvent) {
        mixpanel.track(event: event.rawValue)
    }
    
    public func logEvent(_ event: AnalyticsEvent, with: [String: Any]) {
        mixpanel.track(event: event.rawValue, properties: toMixpanelProperties(with))
    }
    
    public func increment(property: String, by: Double) {
        mixpanel.people.increment(property: property, by: by)
    }
    
    public func setName(for screen: Screen, screenClass: String) {
        mixpanel.track(event: kScreenViewEvent, properties: [
            kScreenNameParam: screen.name,
            kScreenClassParam: screenClass
        ])
    }
    
    public func setUserProperties(_ userInfo: [String : Any], userId: Int) {
        mixpanel.identify(distinctId: String(userId))
    }
    
    public func logRevenue(productId: String, productTitle: String, productItem: RevenueProduct?, value: NSNumber, currency: String) {
        if let productItem {
            mixpanel.people.trackCharge(amount: value.doubleValue, properties: toMixpanelProperties(productItem.params))
        } else {
            mixpanel.people.trackCharge(amount: value.doubleValue)
        }
    }

    public func setupTracking(with status: ATTrackingManager.AuthorizationStatus) {
        //do nothing
    }
    
    public func applicationDidBecomeActive() {
        //do nothing
    }
    
    public func applicationDidLaunchWithOptions(application: UIApplication, _ launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        Mixpanel.initialize(token: "MIXPANEL_TOKEN", trackAutomaticEvents: false)
    }

    private func toMixpanelProperties(_ params: [String: Any]) -> [String: any MixpanelType] {
        params.compactMapValues { value in
            value as? MixpanelType
        }
    }
}
