//
//  LocationManager.swift
//  NiceWeather
//
//  Created by Dirk Clemens on 28.04.23.
//

import Foundation
import CoreLocation

// https://developer.apple.com/documentation/corelocation/configuring_your_app_to_use_location_services
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.location = location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with error: \(error)")
    }
    
    func requestLocation() {
        self.locationManager.requestLocation()
    }
    
    func getLatitude() -> Double {
        self.locationManager.requestLocation()
        return self.locationManager.location?.coordinate.latitude ?? 0.0
    }

    func getLongitude() -> Double {
        self.locationManager.requestLocation()
        return self.locationManager.location?.coordinate.longitude ?? 0.0
    }

    func getCityNameFromLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees, completionHandler: @escaping (String?) -> Void) {
        let location = CLLocation(latitude: self.getLatitude(), longitude: self.getLongitude())
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                completionHandler(nil)
                return
            }
            let city = placemark.locality
            completionHandler(city)
        }
    }
    
    func getCityNameFromLocation(completionHandler: @escaping (String?) -> Void) {
        let location = CLLocation(latitude: self.location?.coordinate.latitude ??  0.0, longitude: self.location?.coordinate.longitude ?? 0.0)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                completionHandler(nil)
                return
            }
            let city = placemark.locality
            completionHandler(city)
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:  // Location services are available.
            //enableLocationFeatures()
            manager.startUpdatingLocation()
            break
            
        case .restricted, .denied:  // Location services currently unavailable.
            //disableLocationFeatures()
            break
            
        case .notDetermined:        // Authorization not determined yet.
            manager.requestWhenInUseAuthorization()
            break
            
        default:
            break
        }
    }
}
