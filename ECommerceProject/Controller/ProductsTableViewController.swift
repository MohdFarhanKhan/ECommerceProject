//
//  ProductsTableViewController.swift
//  ECommerceProject
//
//  Created by Mohd Farhan Khan on 7/18/18.
//  Copyright © 2018 Mohd Farhan Khan. All rights reserved.
//

import UIKit
import CoreData
@available(iOS 11.0, *)
class ProductsTableViewController: UITableViewController{
    var productIDList : [[String:AnyObject]] = []
    var productList : [Product] = []
    var categoryID : Int32 = -1
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(ProductsTableViewController.getData), name: NSNotification.Name(rawValue: "getData"), object: nil)
        self.tableView.tableFooterView = UIView()
        getData()
       
    }
    @objc func getData(){
        if categoryID != -1{
            getProductByCategory()
        }
        else{
            getProductByProductID()
        }
    }
    func getProductByCategory(){
        do{
            productList.removeAll()
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let managedContext = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<EProduct>(entityName: "EProduct")
            request.predicate = NSPredicate(format: "categoryID == \(categoryID)" )
            let results = try managedContext.fetch(request)
            productList = getProducts(fromProducts: results)
            self.tableView.reloadData()
            
        }
        catch{
            print("Error ")
        }
    }
    func getProductByProductID(){
        productList.removeAll()
        for item in productIDList{
            
             do{
                  let productID = item["id"] as! Int32
                  let appDelegate = UIApplication.shared.delegate as! AppDelegate
                  let managedContext = appDelegate.persistentContainer.viewContext
                  let request = NSFetchRequest<EProduct>(entityName: "EProduct")
                  request.predicate = NSPredicate(format: "productID == \(productID)" )
                  let products = try managedContext.fetch(request)
                  let product = getProducts(fromProducts: products)
                   productList.append(product[0])
                
            
              }
              catch{
                   print("Error ")
              }
        }
        self.tableView.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
       return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ProductCell
        let prDict = productList[indexPath.row]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let date = dateFormatter.date(from: prDict.productAddedDate)
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        cell.productNameLabel.text = prDict.productName
        cell.addedDateLabel.text = dateFormatter.string(from: date!)
        cell.viewCountLabel.text = "View:\(String(describing: prDict.productViewCount))"
        cell.shareCountLabel.text = "Share:\(String(describing: prDict.productSharesCount))"
        cell.orderCountLabel.text = "Order:\(String(describing: prDict.productOrderCount))"
        cell.taxLabel.text = " \(prDict.tax!.taxName):\(String(describing: prDict.tax!.taxValue))"
        var i = 0
        var j = 1
        for subview in cell.variantsScrollView.subviews{
            subview.removeFromSuperview()
        }
        
        let lastGesture = cell.variantsScrollView.gestureRecognizers?.last
        if lastGesture?.name == "scroll"{
            cell.variantsScrollView.removeGestureRecognizer(lastGesture!)
        }
        if prDict.variants!.count > 0{
          
            let newGesture = UITapGestureRecognizer(target: self, action: #selector(ProductsTableViewController.scrollViewTapped(_:)))
            
            newGesture.name = "scroll"
            cell.variantsScrollView.addGestureRecognizer(newGesture)
        }
        for variant in prDict.variants!{
            let variantDict = variant
            let variantView : UIView = UIView(frame: CGRect(x: i, y: 0, width: Int(cell.variantsScrollView.frame.size.width), height: Int(cell.variantsScrollView.frame.size.height)))
            
            variantView.tag = j
            let variantLabel : UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: Int(cell.variantsScrollView.frame.size.width), height: Int(cell.variantsScrollView.frame.size.height)))
            var variantText = "Color: \(String(describing: variantDict.variantColor)), Price: \(variantDict.variantPrice), Size: "
            if variantDict.variantSize > 0{
                variantText += "\(variantDict.variantSize)"
            }
            else{
                variantText += "n/a"
            }
            variantLabel.adjustsFontSizeToFitWidth = true
            variantLabel.text = variantText
            variantView.addSubview(variantLabel)
            cell.variantsScrollView.addSubview(variantView)
            i += Int(cell.variantsScrollView.frame.size.width)
            j += 1
            cell.variantsScrollView.delegate = self
            
        }
        cell.variantsScrollView.contentSize = CGSize(width: CGFloat(i), height: cell.variantsScrollView.frame.size.height)
        if prDict.variants!.count <= 0{
            let imgView : UIImageView = cell.viewWithTag(100) as! UIImageView
            imgView.image = nil
            imgView.setNeedsDisplay()
           
        }
        return cell
    }
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.isEqual(self.tableView) == false{
            let pageWidth = scrollView.bounds.width
            let pageFraction = scrollView.contentOffset.x / pageWidth
            let cell = scrollView.superview?.superview as! UITableViewCell
            let indexPath = self.tableView.indexPath(for: cell)
            if indexPath?.row == nil{
                return
            }
            if (indexPath?.row)! >= productList.count{
                return
            }
            let product = productList[(indexPath?.row)!]
            if Int((round(pageFraction+1))) >= (product.variants?.count)!{
                let imgView : UIImageView = cell.viewWithTag(100) as! UIImageView
                imgView.image = nil
                imgView.setNeedsDisplay()
            }
            else{
                let imgView : UIImageView = cell.viewWithTag(100) as! UIImageView
                imgView.image = UIImage(named: "tree_ec")
                imgView.setNeedsDisplay()
            }
        }
    }
    @IBAction func scrollViewTapped(_ sender: Any) {
        let guesture = sender as! UITapGestureRecognizer
        let scrollView = guesture.view as! UIScrollView
        let pageWidth = scrollView.bounds.width
        let pageFraction = scrollView.contentOffset.x / pageWidth
        let cell = scrollView.superview?.superview as! UITableViewCell
        let indexPath = self.tableView.indexPath(for: cell)
        if indexPath?.row == nil{
            return
        }
        let product = productList[(indexPath?.row)!]
        var index = Int(round(pageFraction))
        if index > (product.variants?.count)!-1{
            index -= 1
        }
        let variant = product.variants![index]
        let alert = UIAlertController(title: "\(product.productName)", message: "Color:\(variant.variantColor),Price: \(variant.variantPrice),Size: \(variant.variantSize)", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
       
    }
    

}
