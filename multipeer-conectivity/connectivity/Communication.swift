//
//  Communication.swift
//  multipeer-conectivity
//
//  Created by Vincent Berihuete on 10/17/18.
//  Copyright © 2018 devcorerd. All rights reserved.
//

import Foundation

struct Communication: Codable{
    var type: CommunicationType
    var origin: CommunicationOrigin
    var data: Data
}

enum CommunicationOrigin: Int, Codable{
    case phone
    case pad
}

enum CommunicationType: Int, Codable {
    case products
    case bills
    case tablesCount
    case billCreate
    case billUpdate
    case billDelete
}
