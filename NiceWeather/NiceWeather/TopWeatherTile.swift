//
//  TopWeatherTile.swift
//  NiceWeather
//
//  Created by Dirk Clemens on 24.04.23.
//

import SwiftUI

struct TopWeatherTile: View {
    
    @EnvironmentObject var weatherViewModel: WeatherViewModel

    @StateObject var locationManager = LocationManager()
    @State private var localCity = "..."

    var body: some View {

        if (weatherViewModel.items.count > 0){
            
            let response: WeatherData = weatherViewModel.items.first!
            let current: CurrentWeatherData = response.current
            
            GeometryReader{ g in
                HStack() {
                    VStack(alignment: .center, spacing: 10) {
                        Text("\(localCity)")
                            .font(.custom("Quicksand-Light", size: 30))
                        HStack {
                            Text("Stand:").font(.footnote)
                            Text("\(weatherViewModel.getTimeFromUnixtime(current.dt, timezone: response.timezone))")
                                .font(.footnote)
                            Spacer()
                            Text("\(weatherViewModel.getDateFromUnixtime(current.dt, timezone: response.timezone))")
                                .font(.footnote)
                        }
                        .onAppear(){
                            locationManager.getCityNameFromLocation(latitude: locationManager.getLatitude(), longitude: locationManager.getLongitude()
                            ) { city in
                                if let city = city {
                                    localCity = city
                                }
                            }
                        }
                        HStack {
                            ZStack(){
                                AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(current.weather[0].icon)@2x.png"), content: { image in
                                    image.scaledToFit()
                                }, placeholder: {
                                    ProgressView()
                                })
                                .aspectRatio(contentMode: .fit)
                                .shadow(radius: 1)
                            }
                            .cornerRadius(10)
                            Spacer()
                            Text("\(current.temp.noDec)°")
                                .font(.custom("Quicksand-Bold", size: 80))
                                .bold()
                                .foregroundColor(.yellow)
                                .lineLimit(1)
                        }
                        HStack {
                            Section{
                                Text("\(Double(current.pressure).noDec)hPa").font(.footnote)
                                Spacer()
                                Image(systemName: "humidity").font(.footnote)
                                Text("\(Double(current.humidity).noDec)%").font(.footnote)
                            }
                            Spacer()
                            Section{
                                Image(systemName: "cloud").font(.footnote)
                                Text("\(current.clouds)%").font(.footnote)
                                Spacer()
                                Image(systemName: "wind.circle").font(.footnote)
                                Text("\(weatherViewModel.metersPerSecondToBeaufort(current.wind_speed))Bft /").font(.footnote)
                                Text("\(weatherViewModel.degreesToWindDirection(degrees: Double(current.wind_deg)))").font(.footnote)
                            }
                        }
                        Divider()
                        HStack {
                            Text("\(current.weather[0].description)").font(.footnote)
                            Spacer()
                            Image(systemName: "eye").font(.footnote)
                            Text("\(current.visibility/1000) km").font(.footnote)
                            Spacer()
                            Image(systemName: "sunrise").font(.footnote)
                            Text("\(weatherViewModel.getTimeFromUnixtime(current.sunrise, timezone: response.timezone))").font(.footnote)
                            Spacer()
                            Image(systemName: "sunset").font(.footnote)
                            Text("\(weatherViewModel.getTimeFromUnixtime(current.sunset, timezone: response.timezone))").font(.footnote)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(15)
                .background(Color.white.opacity(0.99))
                .cornerRadius(8)
                .padding(10)
                .modifier(customFontModifier())
            }
        }
    }
}

struct TopWeatherTile_Previews: PreviewProvider {
    static var previews: some View {
        TopWeatherTile()
    }
}
