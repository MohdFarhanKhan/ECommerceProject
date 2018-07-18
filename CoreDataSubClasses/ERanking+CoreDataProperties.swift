//
//  ERanking+CoreDataProperties.swift
//  
//
//  Created by Mohd Farhan Khan on 7/18/18.
//
//

import Foundation
import CoreData


extension ERanking {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ERanking> {
        return NSFetchRequest<ERanking>(entityName: "ERanking")
    }

    @NSManaged public var products: [[String:AnyObject]]?
    @NSManaged public var ranking: String?

}
