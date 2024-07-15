//
//  ForecastWeatherResult.swift
//  DSWeather
//
//  Created by 머성이 on 7/11/24.
//

import Foundation

//테스트용 주석
struct ForecastWeatherResult: Codable {
    let list: [ForecastWeather]
}

struct ForecastWeather: Codable {
    let main: WeatherMain
    let dtTxt: String
    
    enum CodingKeys: String, CodingKey {
        case main
        case dtTxt = "dt_txt"
    }
}
