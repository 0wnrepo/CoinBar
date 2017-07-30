//
//  File.swift
//  CoinBar
//
//  Created by Benny Lach on 30.07.17.
//  Copyright © 2017 DevKiste. All rights reserved.
//

import Foundation

public struct CoinObject {
    let usdPrice: Double
    let btcPrice: Double
    let course: Double
    
    public init(usdPrice: Double, btcPrice: Double, course: Double) {
        self.usdPrice = usdPrice
        self.btcPrice = btcPrice
        self.course = course
    }
}


// MARK: Decodable
extension CoinObject: Decodable {
    private enum CodingKeys: String, CodingKey {
        case usdPrice
        case btcPrice
        case course = "perc"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        // Apparently cointbase uses a String to represent usd price and 24h gap
        let usdPrice = try values.decode(String.self, forKey: .usdPrice)
        let btcPrice = try values.decode(Double.self, forKey: .btcPrice)
        let course = try values.decode(String.self, forKey: .course)
        
        self.usdPrice = Double(usdPrice)!
        self.btcPrice = 1.0 / btcPrice
        self.course = Double(course)!
    }
}
