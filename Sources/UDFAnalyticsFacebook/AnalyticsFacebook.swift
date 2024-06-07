
import Foundation
import UDFAnalytics
import FacebookCore

import class AppTrackingTransparency.ATTrackingManager
import class UIKit.UIApplication

public struct AnalyticsFacebook<Event: RawRepresentable>: UDFAnalytics.Analytics where Event.RawValue == String {

    private var facebook: AppEvents { .shared }

    ///AppsFlyer events mapper
    ///
    ///# Auth login mapping example #
    ///```
    ///switch event {
    ///    case .signIn:
    ///        AppEvents.shared.logEvent(.init("login_method"), parameters: mapProvider(values: with, to: "login_method"))
    ///    case .signUp:
    ///        AppEvents.shared.logEvent(.completedRegistration, parameters: mapProvider(values: with, to: AppEvents.ParameterName.registrationMethod.rawValue))
    ///    default:
    ///        let parameters: [AppEvents.ParameterName: Any] = with.reduce(into: [:]) { result, entry in
    ///            let parameterName = AppEvents.ParameterName(rawValue: entry.key)
    ///            result[parameterName] = entry.value
    ///        }
    ///        AppEvents.shared.logEvent(.init(event.rawValue), parameters: parameters)
    ///}
    ///
    ///func mapProvider(values: [String: Any], to key: String) -> [AppEvents.ParameterName: Any] {
    ///    values.reduce([:]) { dict, pair in
    ///        var mutableDict = dict
    ///        if pair.key == AnalyticsParams.provider.rawValue {
    ///            mutableDict[AppEvents.ParameterName(rawValue: key)] = pair.value
    ///        } else {
    ///            mutableDict[AppEvents.ParameterName(rawValue: pair.key)] = pair.value
    ///        }
    ///        return mutableDict
    ///    }
    ///}
    ///```
    public typealias EventMapper = (_ event: Event, _ params: [String: Any]?) -> (event: AppEvents.Name, params: [AppEvents.ParameterName : Any]?)
    public var eventMapper: EventMapper

    public typealias UserPropertiesMapper = (_ userProperties: [String: Any]) -> [FBSDKAppEventUserDataType: String]
    public var userPropertiesMapper: UserPropertiesMapper

    public init(
        userPropertiesMapper: @escaping UserPropertiesMapper,
        eventMapper: @escaping EventMapper = { event, params in
            var mappedParams: [AppEvents.ParameterName: Any] = [:]
            params?.forEach({ tuple in
                mappedParams[.init(rawValue: tuple.key)] = tuple.value
            })
            return (event, mappedParams)
        }
    ) {
        self.userPropertiesMapper = userPropertiesMapper
        self.eventMapper = eventMapper
    }

    public func logEvent(_ event: Event) {
        let mappedEvent = eventMapper(event, nil)
        facebook.logEvent(mappedEvent.event)
    }
    
    public func logEvent(_ event: Event, with: [String: Any]) {
        let mappedEvent = eventMapper(event, nil)
        facebook.logEvent(mappedEvent.event, parameters: mappedEvent.params)
    }
    
    public func increment(property: String, by: Double) {
        //do nothing
    }

    public func setName(for screen: Screen, screenClass: String, with: [String : Any]?) {
        var properties: [AppEvents.ParameterName: Any] = [
            .init(kScreenNameParam): screen.name,
            .init(kScreenClassParam): screenClass
        ]

        if let with {
            with.forEach { tuple in
                properties[.init(tuple.key)] = tuple.value
            }
        }

        facebook.logEvent(.init(kScreenViewEvent), parameters: properties)
    }

    public func setUserProperties(_ userInfo: [String: Any], userId: Int?) {
        if let userId {
            facebook.userID = String(userId)
        }
        userPropertiesMapper(userInfo).forEach { tuple in
            facebook.setUserData(tuple.value, forType: tuple.key)
        }
    }
    
    public func logRevenue(productId: String, productTitle: String, productItem: UDFAnalytics.RevenueProduct?, value: NSNumber, currency: String) {
        facebook.logPurchase(
            amount: Double(truncating: value),
            currency: currency,
            parameters: [
                AppEvents.ParameterName.contentID: productId,
                AppEvents.ParameterName.contentType: productTitle
            ]
        )
    }
    
    public func setupTracking(with status: ATTrackingManager.AuthorizationStatus) {
        switch status {
        case .authorized:
            Settings.shared.isAdvertiserTrackingEnabled = true
        default:
            Settings.shared.isAdvertiserTrackingEnabled = false
        }
    }
    
    public func applicationDidBecomeActive() {
        //do nothing
    }
    
    public func applicationDidLaunchWithOptions(application: UIApplication, _ launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        DispatchQueue.main.async {
            ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        }
    }
}
