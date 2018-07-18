//
//  ECategory+CoreDataProperties.swift
//  
//
//  Created by Mohd Farhan Khan 7/18/18.
//
//

import Foundation
import CoreData


extension ECategory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ECategory> {
        return NSFetchRequest<ECategory>(entityName: "ECategory")
    }

    @NSManaged public var categoryID: Int32
    @NSManaged public var categoryName: String?
    @NSManaged public var products: [[String:AnyObject]]?
    @NSManaged public var childCategories: [Int32]?

}
