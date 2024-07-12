//
//  CurrentWeatherResult.swift
//  DSWeather
//
//  Created by 머성이 on 7/11/24.
//

import Foundation

struct CurrentWeatherResult: Codable {
    let weather: [Weather]
    let main: WeatherMain
}

struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct WeatherMain: Codable {
    let temp: Double
    let tempMin: Double
    let tempMax: Double
    let humidity: Int
    
    enum CodingKeys: String, CodingKey {
        case temp
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case humidity
    }
}
