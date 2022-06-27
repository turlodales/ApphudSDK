//
//  ApphudInternal+Location.swift
//  ApphudSDK
//
//  Created by Renat Kurbanov on 23.06.2022.
//

import Foundation
import CoreLocation

@available(OSX 10.14.4, *)
class ApphudLocationManager: NSObject, CLLocationManagerDelegate {
    
    lazy var manager = CLLocationManager()
    
    var location: CLLocation? {
        didSet {
            if let coords = location?.coordinate {
                let lat = coords.latitude
                let lng = coords.longitude
                apphudLog("Did receive location: \(lat) \(lng)", logLevel: .debug)
            }
        }
    }
    
    var isUpdatingLocation = false
    
    internal func checkLocationAuthorization() {
        guard CLLocationManager.locationServicesEnabled() else { return }
        guard hasInfoPlistKey else { return }
        guard location == nil else { return }
        
        if #available(iOS 14.0, *) {
            if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
                fetchLocationUpdates()
            }
        } else {
            
        }
    }
    
    private var isIPhone: Bool {
        #if os(iOS)
            return UIDevice.current.userInterfaceIdiom == .phone
        #else
            return false
        #endif
    }
    
    private var hasInfoPlistKey: Bool {
        guard let infoPlist = Bundle.main.infoDictionary else {return false}
        
        return infoPlist["NSLocationAlwaysAndWhenInUseUsageDescription"] != nil || infoPlist["NSLocationWhenInUseUsageDescription"] != nil
    }
    
    private func fetchLocationUpdates() {
        if isUpdatingLocation {
            stopLocationUpdates()
        }
        isUpdatingLocation = true
        manager.stopUpdatingLocation()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        manager.requestLocation()
    }
    
    private func stopLocationUpdates() {
        manager.stopUpdatingLocation()
        isUpdatingLocation = false
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first
        stopLocationUpdates()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        stopLocationUpdates()
    }
}
