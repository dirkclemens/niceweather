//
//  WeatherViewModel.swift
//  Energiebilanz
//
//  Created by Dirk Clemens on 20.04.23.
//

import Foundation
import SwiftUI
import Combine

public class WeatherViewModel: ObservableObject {

    @Published var items: [WeatherData]
    let client = OpenWeatherAPIClient(apiKey: Constants.openWeatherApiKey)
    
    init() {
        self.items = [WeatherData]()
        self.getlocalWeather()
    }
    
    func getlocalWeather() {
        self.getWeather(latitude: Constants.homelat, longitude: Constants.homelon)
    }
    
    func getWeather(latitude: Double, longitude: Double) {
        client.fetchWeatherData(latitude: latitude, longitude: longitude) { result in
            DispatchQueue.main.async {
                let index = 0
                switch result {
                case .success(let response):
                    if (!self.items.indices.contains(index)) {
                        self.items.append(response)
                    } else {
                        self.items[index] = response
                    }
                case .failure(let error):
                    print("Error! \(error)")
                }
            }
        }
    }

    func getCurrentOWApiTime() -> String {
        let dt = self.items.first?.current.dt ?? 0
        let tz = self.items.first?.timezone ?? "Europe/Berlin"
        return getTimeFromUnixtime(dt, timezone: tz)
    }

    func getTimeFromUnixtime(_ unixtime: Int, timezone: String) -> String {
        let date = Date(timeIntervalSince1970: Double(unixtime))
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = NSLocale.current
        formatter.timeZone = TimeZone(identifier: timezone)
        var formattedDate:String {formatter.string(from: date)}
        return formattedDate
    }

    func getCurrentOWApiDate() -> String {
        let dt = self.items.first?.current.dt ?? 0
        let tz = self.items.first?.timezone ?? "Europe/Berlin"
        return getDateFromUnixtime(dt, timezone: tz)
    }

    // https://nshipster.com/formatter/
    func getDateFromUnixtime(_ unixtime: Int, timezone: String) -> String {
        let date = Date(timeIntervalSince1970: Double(unixtime))
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.locale = Locale(identifier: "de_DE")
        formatter.timeZone = TimeZone(identifier: timezone)
        var formattedDate:String {formatter.string(from: date)}
        return formattedDate
    }
    
    func degreesToWindDirection(degrees: Double) -> String {
        let directions = ["N", "NNO", "NO", "ONO", "O", "OSO", "SO", "SSO", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
        let index = Int((degrees / 22.5) + 0.5)
        return directions[index % 16]
    }

    func metersPerSecondToBeaufort(_ metersPerSecond: Double) -> Int {
        let knots = metersPerSecond * 1.94384
        switch knots {
        case 0...1:
            return 0
        case 1...3:
            return 1
        case 3...7:
            return 2
        case 7...12:
            return 3
        case 12...18:
            return 4
        case 18...24:
            return 5
        case 24...31:
            return 6
        case 31...38:
            return 7
        case 38...46:
            return 8
        case 46...54:
            return 9
        case 54...63:
            return 10
        case 63...72:
            return 11
        default:
            return 12
        }
    }
    
}

extension Double {
    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    var celsius:String {
        return String(format: "%.1f°C", self)
    }
    var celsius0:String {
        return String(format: "%.0f°C", self)
    }
    var dec1: String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }
    var dec2: String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }
    var noDec: String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }
}
