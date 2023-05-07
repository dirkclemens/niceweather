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
    private let locationManager = CLLocationManager()

    @Published var location: CLLocation?
    @Published var currentLocation: CLLocation?
    @Published var currentAddress: String?
    @Published var currentCity: String?
    @Published var currentStreet: String?
    @Published var isLoading = false

    var lastLocation: CLLocation?
    let distanceThreshold: CLLocationDistance = 1//0000 // 10 km
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.setup()
    }
    
    private func setup() {
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        self.locationManager.requestWhenInUseAuthorization()
        
//        if CLLocationManager.headingAvailable() {
//            self.locationManager.startUpdatingLocation()
//            self.locationManager.startUpdatingHeading()
//        }
        self.locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print("didUpdateLocations")
        if let location = locations.first {
            if let lastLocation = lastLocation, location.distance(from: lastLocation) >= distanceThreshold {
                self.lastLocation = location // Use self to access the instance variable
//                print("getLocationName(for: \(location))")
//                getLocationName(for: location)
            }
            getLocationName(for: location)
            currentLocation = location
            print("\(location.coordinate.latitude) / \(location.coordinate.longitude)")
        }
        isLoading = false
    }
        
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with error: \(error)")
        isLoading = false
    }

    func getLocationName(for location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                self.currentCity = nil
                self.currentAddress = nil
                return
            }
            let city = placemark.locality
            self.currentCity = city ?? "-"
            print("\(String(describing: city))")
            let address = placemark.formatAddress()
            self.currentAddress = address
            print("\(address)")
        }
    }
    
    func requestLocation() -> Bool {
        isLoading = true
        if (self.locationManager.allowsBackgroundLocationUpdates){
            self.locationManager.requestLocation()
            return true
        } else {
            return false
        }
    }
    
//    func getLatitude() -> Double {
//        //self.locationManager.requestLocation()
//        //return self.locationManager.location?.coordinate.latitude ?? 0.0
//        return self.currentLocation?.coordinate.latitude ?? 0.0
//    }
//
//    func getLongitude() -> Double {
//        //self.locationManager.requestLocation()
//        //return self.locationManager.location?.coordinate.longitude ?? 0.0
//        return self.currentLocation?.coordinate.longitude ?? 0.0
//    }
//
//    func getAltitude() -> Double {
//        //self.locationManager.requestLocation()
//        //return self.locationManager.location?.altitude ?? 0.0
//        return self.currentLocation?.altitude ?? 0.0
//    }
//
//    func getLocation() -> CLLocation {
//        return self.currentLocation ?? CLLocation()
//    }
//
//    func getLocationName() -> String {
//        print("getLocationName() --> \(self.currentCity ?? "...")")
//        return self.currentCity ?? "..."
//    }

    
//    func getCityNameFromLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees, completionHandler: @escaping (String?) -> Void) {
//        let lastLocation = CLLocation(latitude: latitude, longitude: longitude)
//        let geocoder = CLGeocoder()
//        geocoder.reverseGeocodeLocation(lastLocation) { placemarks, error in
//            // Most geocoding requests contain only one result.
//            guard let placemark = placemarks?.last, error == nil else {
//                completionHandler(nil)
//                print("error: \(error.debugDescription)")
//                return
//            }
//            let city = placemark.locality
//            completionHandler(city)
//        }
//    }
//    
//    func getCityNameFromLocation(completionHandler: @escaping (String?) -> Void) {
//        // Use the last reported location.
//        if let lastLocation = self.locationManager.location {
//            let geocoder = CLGeocoder()
//            geocoder.reverseGeocodeLocation(lastLocation) { placemarks, error in
//                // Most geocoding requests contain only one result.
//                guard let placemark = placemarks?.last, error == nil else {
//                    completionHandler(nil)
//                    print("error: \(error.debugDescription)")
//                    return
//                }
//                let city = placemark.locality
//                completionHandler(city)
//            }
//        }
//    }

    /// https://developer.apple.com/documentation/corelocation/converting_between_coordinates_and_user-friendly_place_names
    func lookUpCurrentLocation(completionHandler: @escaping (CLPlacemark?) -> Void ) {
        // Use the last reported location.
        if let lastLocation = self.locationManager.location {
            let geocoder = CLGeocoder()
            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(lastLocation,
                        completionHandler: { (placemarks, error) in
                if error == nil {
                    // Most geocoding requests contain only one result.
                    let firstLocation = placemarks?.last
                    completionHandler(firstLocation)
                }
                else {
                 // An error occurred during geocoding.
                    completionHandler(nil)
                }
            })
        }
        else {
            // No location was available.
            completionHandler(nil)
        }
    }
    
//    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//        switch manager.authorizationStatus {
//        case .authorizedWhenInUse:  // Location services are available.
//            //enableLocationFeatures()
//            //manager.startUpdatingLocation()
//            break
//
//        case .restricted, .denied:  // Location services currently unavailable.
//            //disableLocationFeatures()
//            break
//
//        case .notDetermined:        // Authorization not determined yet.
//            manager.requestWhenInUseAuthorization()
//            break
//
//        default:
//            break
//        }
//    }
}

extension CLPlacemark {
    func formatAddress() -> String {
        var addressString : String = ""
        if let thoroughfare = self.thoroughfare {
            addressString += thoroughfare + " "
        }
        if let subThoroughfare = self.subThoroughfare {
            addressString += subThoroughfare + ", "
        }
        if let postalCode = self.postalCode {
            addressString += postalCode + " "
        }
        if let locality = self.locality {
            addressString += locality + ", "
        }
//        if let administrativeArea = self.administrativeArea {
//            addressString += administrativeArea + " "
//        }
        if let country = self.country {
            addressString += country
        }
        return addressString
    }
}
