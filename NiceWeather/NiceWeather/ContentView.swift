//
//  ContentView.swift
//  NiceWeather
//
//  Created by Dirk Clemens on 21.04.23.
//  https://fuckingswiftui.com/#scrollview

import Foundation
import SwiftUI
import CoreLocation

// https://codewithchris.com/swiftui/swiftui-custom-fonts/
// https://codewithchris.com/common-mistakes-with-adding-custom-fonts-to-your-ios-app/#findfontname
struct customFontModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
//            .font(.custom("Quicksand-Bold", size: 14))
            .font(.custom("VarelaRound-Regular", size: 14))
            .foregroundColor(Color.black)
    }
}

struct ContentView: View  {

    let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [Color.red, Color.yellow]),
        startPoint: .top, endPoint: .bottom)

    @StateObject var weatherViewModel = WeatherViewModel()

    @StateObject var locationManager = LocationManager()

    private let cv_timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    var body: some View {
        
        if locationManager.isLoading {
            ProgressView()
        } else {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()
                VStack {
                    Group {
                        VStack (alignment: .center) {
                            Spacer().frame(height: 30.0)
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
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }        
                    Group {
                        VStack {
                            HStack {
                                TopWeatherTile().environmentObject(weatherViewModel)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Group {
                        VStack {
                            HStack {
                                Text("Ausblick")
                                    .font(.custom("VarelaRound-Regular", size: 20))
                                    .foregroundColor(.white)
                                    .bold()
                                    .padding(.top, 40)
                                    .padding(.leading, 15)
                                    .padding(.bottom, 0)
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
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    //Spacer()
                    Group {
                        HStack {
                            if let currentLocation = locationManager.currentLocation {
                                Text("Latitude: \(currentLocation.coordinate.latitude)")
                                    .font(.footnote)
                                    .foregroundColor(.orange)
                                Text("Longitude: \(currentLocation.coordinate.longitude)")
                                    .font(.footnote)
                                    .foregroundColor(.orange)
                                Text("Alt: \(currentLocation.altitude)")
                                    .font(.footnote)
                                    .foregroundColor(.orange)
                            }
                        } // HStack
                    } // Group

                    //------------------------------------------------------------------------
                    Group {
                        HStack() {
                            Text("made with ").font(.footnote).foregroundColor(.orange)
                            Image(systemName: "apple.logo").foregroundColor(.orange)
                            Text(" by dirk c.").font(.footnote).foregroundColor(.orange)
                            Text(" version: \(version())").font(.footnote).foregroundColor(.orange)
                        } // HStack
                    } // Group
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .modifier(customFontModifier())
                .edgesIgnoringSafeArea(.bottom)
                .preferredColorScheme(.dark)
                .onAppear(){
                    //locationManager.requestLocation()
                    if let currentLocation = locationManager.currentLocation {
                        weatherViewModel.getWeather(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
                    }
                }
                .onTapGesture {
//                    locationManager.requestLocation()
                    if let currentLocation = locationManager.currentLocation {
                        weatherViewModel.getWeather(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
                    }
                }
                .onReceive(cv_timer) { _ in
                    //locationManager.requestLocation()
                    if let currentLocation = locationManager.currentLocation {
                        weatherViewModel.getWeather(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
                    }
                }
            }
        }
    }
}
