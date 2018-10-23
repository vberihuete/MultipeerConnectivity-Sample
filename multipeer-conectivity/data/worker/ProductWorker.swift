//
//  ProductWorker.swift
//  multipeer-conectivity
//
//  Created by Vincent Berihuete on 10/21/18.
//  Copyright © 2018 devcorerd. All rights reserved.
//

import Foundation
import CoreData

struct ProductWorker: Syncable {
    
    typealias Entity = Product
    
    var URL: String{
        return "api://url"
    }
    
    var entityName: String{
        return "Product"
    }
    
    func load(from: LoadSource, callback: ([Product]) -> ()) {
        
    }
    
    func parse(dataFor data: Product) -> NSManagedObject {
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
        let product = NSManagedObject(entity: entity!, insertInto: context)
        product.setValue(data.id, forKey: "id")
        product.setValue(data.description, forKey: "desc")
        product.setValue(data.price, forKey: "price")
        product.setValue(data.title, forKey: "title")
        return product
    }
    
    func parse(dataFrom managedObject: NSManagedObject) -> Product? {
        guard let id = managedObject.value(forKey: "id") as? Int, let desc = managedObject.value(forKey: "desc") as? String, let title = managedObject.value(forKey: "title") as? String, let price = managedObject.value(forKey: "price") as? Double else{
            return nil
        }
        let product = Product(id: id, title: title, description: desc, price: price)
        return product
    }
    
    func load(fromServer limit: Int?, offset: Int?, callback: ([Product]) -> ()){
        //TODO: Change to alamofire call using the provided URL
        var products = [Product]()
        let date = Date()
        for i in 1...1000{
            products.append(Product(id: i, title: "Product #\(i)", description: "This is the listed product number #\(i) added in \(date)", price: Double.random(in: 2000...99999)))
        }
        callback(products)
    }
}
