//
//  Models.swift
//  WeatherApp
//
//  Created by Mohd Farhan Khan on 7/18/18.
//  Copyright © 2018 Mohd Farhan Khan. All rights reserved.
//

import UIKit
import Alamofire
public let apiURL = "https://stark-spire-93433.herokuapp.com/json"
typealias downloadComplete = (Bool,String)
struct Connectivity {
    static let sharedInstance = NetworkReachabilityManager()!
    static var isConnectedToInternet:Bool {
        return self.sharedInstance.isReachable
    }
}
class Tax{
    var taxName = ""
    var taxValue = 0.0
    init(taxName: String, taxValue:Double ){
        self.taxName = taxName
        self.taxValue = taxValue
        
    }
    
}
class Variant{
    var variantID : Int32 = 0
    var variantColor : String = ""
    var variantPrice : Double = 0
    var variantSize : Double = 0
    init(variantID: Int32,variantColor: String, variantPrice: Double, variantSize:Double ){
        self.variantID = variantID
        self.variantColor = variantColor
        self.variantPrice = variantPrice
        self.variantSize = variantSize
    }
}
class Product{
    var categoryID : Int32 = 0
    var productID : Int32 = 0
    var productAddedDate : String = ""
    var productName : String = ""
    var productOrderCount : Int64 = 0
    var productSharesCount : Int64 = 0
    var productViewCount : Int64 = 0
    var tax : Tax? = Tax(taxName: "", taxValue: 0)
    var variants : [Variant]?
    init(categoryID: Int32,productID: Int32,productAddedDate: String,productName: String, productOrderCount:Int64 , productSharesCount:Int64, productViewCount:Int64, tax: ETax?, variants: [EVariant]?  ){
        self.categoryID = categoryID
        self.productID = productID
        self.productAddedDate = productAddedDate
        self.productName = productName
        self.productOrderCount = productOrderCount
        self.productSharesCount = productSharesCount
        self.productViewCount = productViewCount
        self.tax = Tax(taxName: (tax?.taxName)!, taxValue: (tax?.taxValue)!)
        var newVariants : [Variant]? = []
        for eVariant in variants!{
            let variant = Variant(variantID: eVariant.variantID, variantColor: eVariant.variantColor!, variantPrice: eVariant.variantPrice, variantSize: eVariant.variantSize)
            newVariants?.append(variant)
        }
        self.variants = newVariants
    }
}
struct categoryStruct{
    let category : ECategory
    var categoryArray : [categoryStruct]
}
struct DisplayStruct{
    let id : Int
    let pid : Int
    let level : [Int]
    let name : String
    let prCount : Int
    
}
enum DataKeys: String{
    case categoryKey = "categories"
    case IdKey = "id"
    case nameKey = "name"
    case childCategoriesKey = "child_categories"
    case productsKey = "products"
    case dateKey = "date_added"
    case taxKey = "tax"
    case valueKey = "value"
    case variantsKey = "variants"
    case colorKey = "color"
    case sizeKey = "size"
    case priceKey = "price"
    case rankingsKey = "rankings"
    case rankingKey = "ranking"
    case viewCountKey = "view_count"
    case orderCountsKey = "order_count"
    case sharesKey = "shares"
    case mostViewedProducts = "Most Viewed Products"
    case mostOrderProducts = "Most OrdeRed Products"
    case mostSharedProducts = "Most ShaRed Products"
    
}
func getProducts(fromProducts: [EProduct])->[Product]{
    if fromProducts.count <= 0{
        return []
    }
    var products : [Product] = []
    for eProduct in fromProducts{
        let product : Product = Product(categoryID: eProduct.categoryID, productID: eProduct.productID, productAddedDate: eProduct.productAddedDate!, productName: eProduct.productName!, productOrderCount: eProduct.productOrderCount, productSharesCount: eProduct.productSharesCount, productViewCount: eProduct.productViewCount, tax: eProduct.tax, variants: eProduct.variants?.allObjects as? [EVariant])
        products.append(product)
    }
    return products
}

