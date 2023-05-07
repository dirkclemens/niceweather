//
//  Common.swift
//  NiceWeather
//
//  Created by Dirk Clemens on 07.05.23.
//

import Foundation

/*
    print build version and date
    https://developer.apple.com/library/archive/qa/qa1827/_index.html
    https://www.theswift.dev/posts/easily-keep-build-numbers-and-marketing-versions-in-sync
    https://jellystyle.com/2015/07/versioning-with-xcode
 */
func version() -> String {
    let dictionary = Bundle.main.infoDictionary!
    //print("\(dictionary)")
    let version = dictionary["CFBundleShortVersionString"] as! String
    let build = dictionary["CFBundleVersion"] as! String
    return "\(version) build \(build)"
}
