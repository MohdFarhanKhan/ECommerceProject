//
//  EVariant+CoreDataProperties.swift
//  
//
//  Created by Mohd Farhan Khan on 7/18/18.
//
//

import Foundation
import CoreData


extension EVariant {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EVariant> {
        return NSFetchRequest<EVariant>(entityName: "EVariant")
    }

    @NSManaged public var variantColor: String?
    @NSManaged public var variantID: Int32
    @NSManaged public var variantPrice: Double
    @NSManaged public var variantSize: Double

}
