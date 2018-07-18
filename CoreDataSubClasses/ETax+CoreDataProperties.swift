//
//  ETax+CoreDataProperties.swift
//  
//
//  Created by Mohd Farhan Khan on 7/18/18.
//
//

import Foundation
import CoreData


extension ETax {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ETax> {
        return NSFetchRequest<ETax>(entityName: "ETax")
    }

    @NSManaged public var taxName: String?
    @NSManaged public var taxValue: Double

}
