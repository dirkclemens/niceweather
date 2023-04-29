//
//  ContentView.swift
//  NiceWeather
//
//  Created by Dirk Clemens on 21.04.23.
//  https://fuckingswiftui.com/#scrollview

import Foundation
import SwiftUI
import CoreLocation

//  https://codewithchris.com/swiftui/swiftui-custom-fonts/
struct customFontModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom("Quicksand-Bold", size: 14))
            .foregroundColor(Color.black)
    }
}

struct ContentView: View  {

    let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [Color.red, Color.yellow]),
        startPoint: .top, endPoint: .bottom)

    @StateObject var weatherViewModel = WeatherViewModel()

    @StateObject var locationManager = LocationManager()

    var body: some View {
        
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
            VStack {
                Group {
                    VStack (alignment: .center) {
                        Spacer().frame(height: 35.0)
                        HStack {
                            Spacer()
                            Image(systemName: "sun.max.fill")
                                .font(.largeTitle)
                                .foregroundColor(.yellow)
                                .bold()
                            Text("wetter")
                                .font(.custom("VarelaRound-Regular", size: 36))
                                .foregroundColor(.yellow)
                                .bold()
                            Spacer()
                        }
                    }
                }        
                Group {
                    VStack {
                        HStack {
                            TopWeatherTile().environmentObject(weatherViewModel)
                        }
                    }
                }
                Group {
                    VStack {
                        HStack {
                            Text("Ausblick")
                                .font(.custom("VarelaRound-Regular", size: 24))
                                .foregroundColor(.white)
                                .bold()
                                .padding([.top, .leading], 20)
                            Spacer()
                        }
                        GeometryReader{g in
                            ScrollView(.horizontal, showsIndicators: true) {
                                HStack(spacing: 10) {
                                    ForEach(0..<24) {
                                        WeatherTile(hour: $0).environmentObject(weatherViewModel)
                                            .frame(width: g.size.width * 0.27)
                                            .frame(minWidth: g.size.width * 0.25)
                                            .frame(maxWidth: g.size.width * 0.28)
                                    }
                                    Spacer()
                                }
                            }                        
                            .padding(.leading, 12)
                        }
                    }
                }
                //Spacer()
                Group {
                    HStack {
                        Text("Latitude: \(locationManager.getLatitude())")
                            .font(.footnote)
                            .foregroundColor(.orange)
                        Text("Longitude: \(locationManager.getLongitude())")
                            .font(.footnote)
                            .foregroundColor(.orange)
                    }
                }
            }
            .modifier(customFontModifier())
            .onAppear(){
                weatherViewModel.getWeather(latitude: locationManager.getLatitude(), longitude: locationManager.getLongitude())

            }
            .onTapGesture {
                weatherViewModel.getWeather(latitude: locationManager.getLatitude(), longitude: locationManager.getLongitude())
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
