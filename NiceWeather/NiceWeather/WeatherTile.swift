//
//  WeatherTile.swift
//  NiceWeather
//
//  Created by Dirk Clemens on 21.04.23.
//

import SwiftUI

struct WeatherTile: View {

    @EnvironmentObject var weatherViewModel: WeatherViewModel
    var hour: Int

    var body: some View {
        
        if (weatherViewModel.items.count > 0){

            let response: WeatherData = weatherViewModel.items.first!
            let hourly: [HourlyWeatherData] = response.hourly
            let element = hourly[hour]
            
            GeometryReader{g in
                HStack(alignment: .center) {
                    VStack(alignment: .center, spacing: 5) {
                        Text("\(weatherViewModel.getTimeFromUnixtime(element.dt, timezone: response.timezone))")
                            .font(.custom("VarelaRound-Regular", size: 16))
                        Spacer().frame(height: 1.0)
                        ZStack(){
                            AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(element.weather[0].icon).png"), content: { image in image.fixedSize()
                            }, placeholder: {
                                ProgressView()
                            })
                            .shadow(radius: 1)
                        }
                        .cornerRadius(6)
                        Spacer().frame(height: 1.0)
                        Text("\(element.temp.celsius0)")
                            .font(.custom("VarelaRound-Regular", size: 16))
//                        HStack {
//                            Image(systemName: "humidity").font(.footnote)
//                            Text("\(Double(element.humidity).noDec)%")
//                                .font(.custom("Quicksand-Light", size: 10))
//                            Image(systemName: "cloud")
//                            Text("\(Double(element.pop * 100).noDec)%")
//                                .font(.custom("Quicksand-Light", size: 10))
//                        }
                        Text("\(element.weather[0].description)")
                            .lineLimit(1)
                            .font(.custom("VarelaRound-Regular", size: 10))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(minWidth: g.size.width * 0.24)
                .padding(5)
                .background(Color.white)
                .cornerRadius(8)
                .modifier(customFontModifier())
            }
        }
    }
}

struct WeatherTile_Previews: PreviewProvider {
    static var previews: some View {
        WeatherTile(hour: 0)
    }
}
