//
//  EProduct+CoreDataProperties.swift
//  
//
//  Created by Mohd Farhan Khan on 7/18/18.
//
//

import Foundation
import CoreData


extension EProduct {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EProduct> {
        return NSFetchRequest<EProduct>(entityName: "EProduct")
    }

    @NSManaged public var categoryID: Int32
    @NSManaged public var productAddedDate: String?
    @NSManaged public var productID: Int32
    @NSManaged public var productName: String?
    @NSManaged public var productOrderCount: Int64
    @NSManaged public var productSharesCount: Int64
    @NSManaged public var productViewCount: Int64
    @NSManaged public var tax: ETax?
    @NSManaged public var variants: NSSet?

}

// MARK: Generated accessors for variants
extension EProduct {

    @objc(addVariantsObject:)
    @NSManaged public func addToVariants(_ value: EVariant)

    @objc(removeVariantsObject:)
    @NSManaged public func removeFromVariants(_ value: EVariant)

    @objc(addVariants:)
    @NSManaged public func addToVariants(_ values: NSSet)

    @objc(removeVariants:)
    @NSManaged public func removeFromVariants(_ values: NSSet)

}
