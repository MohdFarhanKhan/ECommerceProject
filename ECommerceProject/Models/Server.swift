













//
//  Server.swift
//  ECommerceProject
//
//  Created by Mohd Farhan Khan on 7/18/18.
//  Copyright © 2018 Mohd Farhan Khan. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import CoreData

class Server{
    static let sharedInstance = Server()
    static var isDataDownloaded = false
    static var isDataBeingDownloaded = false
    private var mainJSONArray : [ECategory] = []
    private var categoryArray : [[String:AnyObject]] = []
    private var rankingArray : [[String:AnyObject]] = []
    private var finalJSONArray : [categoryStruct] = []
    private var displayArray : [DisplayStruct] = []
    init(){
       downloadData()
    }
    func getCategoryDict(levelArray: [Int])->ECategory{
         let categoryObject = goToLevel(array: finalJSONArray, lvlArray: levelArray) as ECategory
         return categoryObject
    }
    func goToLevel(array: [categoryStruct], lvlArray: [Int])->ECategory{
        let newArray = array[lvlArray[0]].categoryArray
        var  newLevelArraySlice = lvlArray[0...(lvlArray.count-1)]
        if lvlArray.count > 1{
             newLevelArraySlice = lvlArray[1...(lvlArray.count-1)]
        }
        else{
            return array[lvlArray[0]].category
        }
        let newLevelArray = Array(newLevelArraySlice) as [Int]
        return goToLevel(array: newArray, lvlArray: newLevelArray)
    }
    func getDisplayCategoryArray(array: [ECategory])->[DisplayStruct]{
        if array.count <= 0{
            return []
        }
        mainJSONArray = array
        mainJSONArray.sort(by: { (item1, item2) -> Bool in
            return item1.categoryID  < item2.categoryID
        })
        var mainCategoryArray : [ECategory] = []
        var subCategoryArray : [ECategory] = []
        for itemDict in mainJSONArray{
            putElementsInProperWay(item: itemDict, array1:&mainCategoryArray, array2:&subCategoryArray)
        }
      
        if mainCategoryArray.count > 1{
            var changeItems : [ECategory] = []
            for i in 0...(mainCategoryArray.count-2){
                let mainItem = mainCategoryArray[i]
                let mainItemIDs = mainItem.childCategories
                for j in (i+1)...(mainCategoryArray.count-1){
                    let item = mainCategoryArray[j]
                    let itemID = item.categoryID
                    var isThisItemCategory = false
                    for mainItemID in mainItemIDs!{
                        if mainItemID == itemID{
                            isThisItemCategory = true
                            break
                        }
                    }
                    if isThisItemCategory == true{
                        changeItems.append(mainCategoryArray[j])
                    }
                }
            }
            for item in changeItems{
                subCategoryArray.append(item)
                let index =  mainCategoryArray.index(where: { $0.categoryID == item.categoryID })
                if let deleteIndex = index{
                        mainCategoryArray.remove(at: deleteIndex)
                }
                
            }
        }
        
        for item in mainCategoryArray{
            var node : categoryStruct = categoryStruct(category: item as ECategory, categoryArray: [])
            getNextArray(array: &node.categoryArray , itemID: Int(item.categoryID))
            finalJSONArray.append(node)
        }
        
        for i in 1...finalJSONArray.count{
            let item = finalJSONArray[i-1]
            let idNo = displayArray.count+1
            let nodeDisplay : DisplayStruct = DisplayStruct(id:idNo , pid: 0, level: [i-1], name: item.category.categoryName!, prCount: (item.category.products?.count)! )
            displayArray.append(nodeDisplay)
            if item.categoryArray.count > 0{
                setDisplayElement(array: item.categoryArray, level: [i-1], i: idNo)
            }
        }
       
        return displayArray
    }
    func putElementsInProperWay(item: ECategory, array1:inout [ECategory], array2:inout [ECategory]){
        if array1.count <= 0{
            array1.append(item)
            return
        }
        let subCategoryIdArray = item.childCategories
        for categoryID in subCategoryIdArray!{
            var index = -1
            var idx = -1
            for item in array1{
                idx += 1
                if item.categoryID  == categoryID{
                    index = idx
                    break
                }
            }
            if index != -1{
                let item = array1[index]
                array1.remove(at: index)
                array2.append(item)
            }
        }
        array1.append(item)
    }
    func getItemIDArray(forID: Int)->[Int32]{
        var idArray : [Int32] = []
        for item in mainJSONArray{
            let itemID = item.categoryID
            if itemID == forID{
                idArray = item.childCategories!
                break
            }
        }
        return idArray
    }
    func getItem(withID: Int)->ECategory?{
        var newItem : ECategory? = nil
        for item in mainJSONArray{
            let itemID = item.categoryID
            if itemID == withID{
                newItem = item
                break
            }
        }
        return newItem
    }
    func getNextArray(array: inout [categoryStruct], itemID: Int){
        let idArray = getItemIDArray(forID: itemID)
        if idArray.count <= 0{
            return
        }
        for itemID in idArray{
            
            var node : categoryStruct = categoryStruct(category: getItem(withID: Int(itemID))!, categoryArray: [])
            getNextArray(array: &node.categoryArray , itemID: Int(itemID))
            array.append(node)
        }
    }
    func setDisplayElement(array: [categoryStruct], level: [Int], i: Int ){
        if array.count <= 0{
            return
        }
        var k = 0
        for item in array{
            let newLevel = level + [k]
            let idNo = displayArray.count+1
            
            let nodeDisplay : DisplayStruct = DisplayStruct(id: idNo, pid: i, level: newLevel, name: item.category.categoryName!, prCount: (item.category.products?.count)!)
            displayArray.append(nodeDisplay)
            if item.categoryArray.count > 0{
                setDisplayElement(array: item.categoryArray, level: newLevel, i: idNo)
            }
            k += 1
        }
    }
 private func getViewCountOrderCountAndShareCount(forId: Int32)->(viewCount: Int32, orderCount: Int32, shareCount: Int32){
        var viewCount : Int32 = 0
       var orderCount : Int32 = 0
       var shareCount : Int32 = 0
       for itemDict in rankingArray{
            if itemDict[String(describing: DataKeys.rankingKey.rawValue)] as! String == DataKeys.mostViewedProducts.rawValue{
                let products = itemDict[String(describing: DataKeys.productsKey.rawValue)] as! [[String:AnyObject]]
                for product in products{
                    if product[String(describing: DataKeys.IdKey.rawValue)] as! Int32 == forId{
                        viewCount = product[String(describing: DataKeys.viewCountKey.rawValue)] as! Int32
                        break
                    }
                }
            }
            else if itemDict[String(describing: DataKeys.rankingKey.rawValue)] as! String == DataKeys.mostOrderProducts.rawValue{
                let products = itemDict[String(describing: DataKeys.productsKey.rawValue)] as! [[String:AnyObject]]
                for product in products{
                    if product[String(describing: DataKeys.IdKey.rawValue)] as! Int32 == forId{
                        orderCount = product[String(describing: DataKeys.orderCountsKey.rawValue)] as! Int32
                        break
                    }
                }
            }
            else if itemDict[String(describing: DataKeys.rankingKey.rawValue)] as! String == DataKeys.mostSharedProducts.rawValue{
                let products = itemDict[String(describing: DataKeys.productsKey.rawValue)] as! [[String:AnyObject]]
                for product in products{
                    if product[String(describing: DataKeys.IdKey.rawValue)] as! Int32 == forId{
                        shareCount = product[String(describing: DataKeys.sharesKey.rawValue)] as! Int32
                        break
                    }
                }
            }
        }
        return (viewCount: viewCount, orderCount: orderCount, shareCount: shareCount)
    }
    func downloadData(){
        
        self.downloadDataFromServer(){isSuccess,error in
            if isSuccess == true{
                self.saveProductsToLocalStorage()
            }
        }
        
    }
    private func downloadDataFromServer(completion: @escaping (_ isSuccess: Bool?, _ error: Error?)->()){
         Server.isDataBeingDownloaded = true
       
         Alamofire.request( URL(string: apiURL)!,
                           method: .get).validate().responseJSON { (response) -> Void in
                            if response.result.error != nil{
                                completion(false, response.result.error!)
                            }
                            let errorString = response.result.error?.localizedDescription
                            if errorString == "The Internet connection appears to be offline."{
                                completion(false, nil)
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "InternetDisconnectedMessage"), object: nil, userInfo: nil)
                               
                            }
                           
                           do {
                                let dict = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String:AnyObject]
                                self.mainJSONArray.removeAll()
                                self.mainJSONArray.removeAll()
                                self.categoryArray.removeAll()
                                self.rankingArray.removeAll()
                                self.finalJSONArray.removeAll()
                                self.displayArray.removeAll()
                                self.categoryArray = dict[String(describing: DataKeys.categoryKey.rawValue)] as! [[String : AnyObject]]
                                self.rankingArray = dict[String(describing: DataKeys.rankingsKey.rawValue)] as! [[String : AnyObject]]
                                completion(true, nil)
                            } catch let myJSONError {
                                completion(false, myJSONError)
                            }
         }
        
    }
   
    private func saveProductsToLocalStorage(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        DispatchQueue.main.async  {
            do{
               let managedContext = appDelegate.persistentContainer.viewContext
               let request1 = NSFetchRequest<EProduct>(entityName: "EProduct")
               let results1 = try managedContext.fetch(request1)
               if results1.count > 0{
                    for item in results1{
                        managedContext.delete(item)
                    }
               }
               for item in self.categoryArray{
                   let products = item[String(describing: DataKeys.productsKey.rawValue)] as! [[String:AnyObject]]
                   for product in products{
                       let entity = NSEntityDescription.entity(forEntityName: "EProduct",
                                                            in: managedContext)!
                       let productObject = EProduct(entity: entity, insertInto: managedContext)
                       productObject.productID = product[String(describing: DataKeys.IdKey.rawValue)] as! Int32
                       productObject.categoryID = item[String(describing: DataKeys.IdKey.rawValue)] as! Int32
                       productObject.productAddedDate = product[String(describing: DataKeys.dateKey.rawValue)] as? String
                       productObject.productName = product[String(describing: DataKeys.nameKey.rawValue)] as? String
                       let viewOrderShareCount = self.getViewCountOrderCountAndShareCount(forId: product[String(describing: DataKeys.IdKey.rawValue)] as! Int32)
                       productObject.productViewCount = Int64(viewOrderShareCount.viewCount)
                       productObject.productSharesCount = Int64(viewOrderShareCount.shareCount)
                       productObject.productOrderCount = Int64(viewOrderShareCount.orderCount)
                       var variantSet : [EVariant] = []
                       let variants = product[String(describing: DataKeys.variantsKey.rawValue)] as! [[String:AnyObject]]
                       for variant in variants{
                           let variantEntity = NSEntityDescription.entity(forEntityName: "EVariant",
                                                                       in: managedContext)!
                           let variantObject = EVariant(entity: variantEntity, insertInto: managedContext)
                           variantObject.variantID = variant[String(describing: DataKeys.IdKey.rawValue)] as! Int32
                           variantObject.variantColor = (variant[String(describing: DataKeys.colorKey.rawValue)] as! String)
                           if !(variant[String(describing: DataKeys.sizeKey.rawValue)] is NSNull) {
                                variantObject.variantSize = variant[String(describing: DataKeys.sizeKey.rawValue)] as! Double
                           }
                           if !(variant[String(describing: DataKeys.priceKey.rawValue)]  is NSNull) {
                                variantObject.variantPrice = variant[String(describing: DataKeys.priceKey.rawValue)] as! Double
                            }
                           variantSet.append(variantObject)
                       }
                       productObject.addToVariants(NSSet(array: variantSet))
                       let tax = product[String(describing: DataKeys.taxKey.rawValue)] as! [String:AnyObject]
                       let taxEntity = NSEntityDescription.entity(forEntityName: "ETax",
                                                                   in: managedContext)!
                      let taxObject = ETax(entity: taxEntity, insertInto: managedContext)
                      taxObject.taxName = (tax[String(describing: DataKeys.nameKey.rawValue)] as! String)
                      taxObject.taxValue = (tax[String(describing: DataKeys.valueKey.rawValue)] as! Double)
                      productObject.tax = taxObject
                   }
               }
               self.saveRankingToLocalStorage()
            }
            catch{
                print("Error")
            }
        }
    }
    private func saveRankingToLocalStorage(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        DispatchQueue.main.async{
            do{
                let managedContext = appDelegate.persistentContainer.viewContext
                let request1 = NSFetchRequest<ERanking>(entityName: "ERanking")
                let results1 = try managedContext.fetch(request1)
                if results1.count > 0{
                    for item in results1{
                        managedContext.delete(item)
                    }
                }
                for item in self.rankingArray{
                    let entity = NSEntityDescription.entity(forEntityName: "ERanking",
                                                            in: managedContext)!
                    let rankingObject = ERanking(entity: entity, insertInto: managedContext)
                    rankingObject.ranking = (item[String(describing: DataKeys.rankingKey.rawValue)] as! String)
                    rankingObject.products = item[String(describing: DataKeys.productsKey.rawValue)] as? [[String:AnyObject]]
                }
                self.saveCategoryToLocalStorage()
            }
            catch{
                print("Error")
            }
        }
    }
    private func saveCategoryToLocalStorage(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        DispatchQueue.main.async{
            do{
                let managedContext = appDelegate.persistentContainer.viewContext
                let request1 = NSFetchRequest<ECategory>(entityName: "ECategory")
                let results1 = try managedContext.fetch(request1)
                if results1.count > 0{
                    for item in results1{
                        managedContext.delete(item)
                    }
                }
                for item in self.categoryArray{
                    let entity = NSEntityDescription.entity(forEntityName: "ECategory",
                                                            in: managedContext)!
                    let categoryObject = ECategory(entity: entity, insertInto: managedContext)
                    categoryObject.categoryID = (item[String(describing: DataKeys.IdKey.rawValue)] as! Int32)
                    categoryObject.categoryName = item[String(describing: DataKeys.nameKey.rawValue)] as? String
                    categoryObject.products = item[String(describing: DataKeys.productsKey.rawValue)] as? [[String:AnyObject]]
                    categoryObject.childCategories = item[String(describing: DataKeys.childCategoriesKey.rawValue)] as? [Int32] 
                }
                Server.isDataDownloaded = true
                Server.isDataBeingDownloaded = false
                do{
                    try managedContext.save()
                }
                catch{
                    print("Error in saving")
                }
            }
            catch{
                print("Error")
            }
        }
    }
    
}
