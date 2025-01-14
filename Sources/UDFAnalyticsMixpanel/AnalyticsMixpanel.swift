
import Foundation
import UDF
import UDFAnalytics
import class AppTrackingTransparency.ATTrackingManager
#if canImport(UIKit)
import UIKit.UIApplication
#else
import AppKit.NSApplication
#endif
import Mixpanel

public struct AnalyticsMixpanel<Event: RawRepresentable>: UDFAnalytics.Analytics where Event.RawValue == String {
    public let token: String
    public let trackAutomaticEvents: Bool
    public let optOutTrackingByDefault: Bool

    private var mixpanel: MixpanelInstance { Mixpanel.mainInstance() }

    public init(token: String, trackAutomaticEvents: Bool = false, optOutTrackingByDefault: Bool = true) {
        self.token = token
        self.trackAutomaticEvents = trackAutomaticEvents
        self.optOutTrackingByDefault = optOutTrackingByDefault
    }

    public func logEvent(_ event: Event) {
        mixpanel.track(event: event.rawValue)
    }
    
    public func logEvent(_ event: Event, with: [String: Any]) {
        mixpanel.track(event: event.rawValue, properties: toMixpanelProperties(with))
    }
    
    public func increment(property: String, by: Double) {
        mixpanel.people.increment(property: property, by: by)
    }
    
    public func setName(for screen: Screen, screenClass: String, with: [String : Any]?) {
        var properties: [String: MixpanelType] = [
            kScreenNameParam: screen.name,
            kScreenClassParam: screenClass
        ]

        if let with {
            with.forEach { tuple in
                if let mixpanelValue = tuple.value as? MixpanelType {
                    properties[tuple.key] = mixpanelValue
                }
            }
        }

        mixpanel.registerSuperProperties([kScreenNameParam: screen.name])
        mixpanel.track(event: kScreenViewEvent, properties: properties)
    }

    public func setUserProperties(_ userInfo: [String: Any], userId: String?) {
        if let userId {
            mixpanel.identify(distinctId: userId)
        }
        mixpanel.people.set(properties: toMixpanelProperties(userInfo))
        if let email = userInfo["email"] as? String {
            mixpanel.people.set(property: "$email", to: email)
        }
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
    
    public func applicationDidLaunchWithOptions(application: PlatformApplication, _ launchOptions: PlatformLaunchOptions) {
        #if canImport(UIKit)
        Mixpanel.initialize(token: token, trackAutomaticEvents: trackAutomaticEvents, optOutTrackingByDefault: optOutTrackingByDefault)
        #else
        Mixpanel.initialize(token: token, optOutTrackingByDefault: optOutTrackingByDefault)
        #endif
    }

    private func toMixpanelProperties(_ params: [String: Any]) -> [String: any MixpanelType] {
        params.compactMapValues { value in
            value as? MixpanelType
        }
    }
}
