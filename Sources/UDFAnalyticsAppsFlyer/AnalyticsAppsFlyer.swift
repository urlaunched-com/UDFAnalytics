
import Foundation
import UDFAnalytics
import AppsFlyerLib
import class AppTrackingTransparency.ATTrackingManager
import class UIKit.UIApplication

public struct AnalyticsAppsFlyer<Event: RawRepresentable>: UDFAnalytics.Analytics where Event.RawValue == String {
    private var appsFlyer: AppsFlyerLib { .shared() }
    
    ///AppsFlyer events mapper
    ///
    ///# Auth login mapping example #
    ///```
    ///switch event {
    ///case .signIn:
    ///     appsFlyer.logEvent(AFEventLogin, withValues: mapProvider(values: with, to: "login_method"))
    ///case .signUp:
    ///     appsFlyer.logEvent(AFEventCompleteRegistration, withValues: mapProvider(values: with, to: AFEventParamRegistrationMethod))
    ///default:
    ///     appsFlyer.logEvent(event.rawValue, withValues: with)
    ///}
    ///
    ///func mapProvider(values: [String: Any], to key: String) -> [String: Any] {
    ///    values.reduce([:]) { dict, pair in
    ///        var mutableDict = dict
    ///        if pair.key == AnalyticsParams.provider.rawValue {
    ///            mutableDict[key] = pair.value
    ///        } else {
    ///            mutableDict[pair.key] = pair.value
    ///        }
    ///    return mutableDict
    ///}
    ///```
    public typealias EventMapper = (_ event: Event, _ params: [String: Any]?) -> (event: String, params: [String: Any]?)
    public var eventMapper: EventMapper

    public init(eventMapper: @escaping EventMapper = { ($0.rawValue, $1) }) {
        self.eventMapper = eventMapper
    }

    public func logEvent(_ event: Event) {
        let mappedEvent = eventMapper(event, nil)
        appsFlyer.logEvent(mappedEvent.event, withValues: mappedEvent.params)
    }
    
    public func logEvent(_ event: Event, with: [String: Any]) {
        let mappedEvent = eventMapper(event, with)
        appsFlyer.logEvent(mappedEvent.event, withValues: mappedEvent.params)
    }
    
    public func increment(property: String, by: Double) {
        //do nothing
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

        appsFlyer.logEvent(kScreenViewEvent, withValues: properties)
    }
    
    public func setUserProperties(_ userInfo: [String: Any], userId: Int?) {
        if let userId {
            appsFlyer.customerUserID = String(userId)
        }
        appsFlyer.customData = userInfo
    }
    
    public func logRevenue(productId: String, productTitle: String, productItem: RevenueProduct?, value: NSNumber, currency: String) {
        var parameters: [String: Any] = [
            AFEventParamContentId: productId,
            AFEventParamContentType: productTitle,
            AFEventParamRevenue: value,
            AFEventParamCurrency: currency
        ]

        if let productItem {
            productItem.params.forEach { tuple in
                parameters[tuple.key] = tuple.value
            }
        }
        appsFlyer.logEvent(AFEventPurchase, withValues: parameters)
    }
    
    public func setupTracking(with status: ATTrackingManager.AuthorizationStatus) {
        //do nothing
    }
    
    public func applicationDidBecomeActive() {
        DispatchQueue.main.async {
            appsFlyer.start()
        }
    }
    
    public func applicationDidLaunchWithOptions(application: UIApplication, _ launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        //do nothing
    }
}
