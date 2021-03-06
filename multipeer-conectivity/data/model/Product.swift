//
//  Product.swift
//  multipeer-conectivity
//
//  Created by Vincent Berihuete on 10/18/18.
//  Copyright © 2018 devcorerd. All rights reserved.
//

import Foundation

struct Product: Codable{
    var id: Int
    var title: String
    var description: String
    var price: Double
    
    init(id: Int, title: String, description: String, price: Double) {
        self.id = id
        self.title  = title
        self.description = description
        self.price = price
    }
}
