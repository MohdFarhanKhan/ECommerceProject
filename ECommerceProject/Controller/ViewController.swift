//
//  ViewController.swift
//  ECommerceProject
//
//  Created by Mohd Farhan Khan on 7/18/18.
//  Copyright © 2018 Mohd Farhan Khan. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import MBProgressHUD
@available(iOS 11.0, *)

class ViewController: UIViewController {
    var displayArray : [DisplayStruct] = []
    var rankingArray : [ERanking] = []
    var categoryDict: ECategory?
    var rankingDict : ERanking?
    var treeView : TreeTableView?
    var isInternetAwailable = false
    var isPullToRefresh = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.categoryTapped(notification:)), name: NSNotification.Name(rawValue: "categoryTapped"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.rankingTapped(notification:)), name: NSNotification.Name(rawValue: "rankingTapped"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.InternetDisconnectedMessage), name: NSNotification.Name(rawValue: "InternetDisconnectedMessage"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.downloadDataOnPullToRefresh), name: NSNotification.Name(rawValue: "downloadDataOnPullToRefresh"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didSaveContext), name: .NSManagedObjectContextDidSave, object: nil)
       CheckNetwork()
       
        isInternetAwailable = true
        self.title = "Categories"
      
      //
    
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    func CheckNetwork() {
        if Connectivity.isConnectedToInternet {
            print("Connected")
             dataDownloadedFromServer()
        } else {
            print("No Internet")
            internetDisconnected()
            do{
                displayArray.removeAll()
                rankingArray .removeAll()
                categoryDict = nil
                rankingDict = nil
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let managedContext = appDelegate.persistentContainer.viewContext
                let request = NSFetchRequest<ECategory>(entityName: "ECategory")
                let results = try managedContext.fetch(request)
                displayArray = Server.sharedInstance.getDisplayCategoryArray(array: results)
                let rankRequest = NSFetchRequest<ERanking>(entityName: "ERanking")
                rankingArray = try managedContext.fetch(rankRequest)
               
                displayData()
            }
            catch{
                print("Error ")
            }
        }
    }
    
    func internetConnected(){
        if Server.isDataBeingDownloaded == false && Server.isDataDownloaded == false{
            Server.sharedInstance.downloadData()
        }
    }
    @objc func InternetDisconnectedMessage(){
        DispatchQueue.main.async(execute: { () -> Void in
           
                MBProgressHUD.hide(for: self.view, animated: true)
            let alert = UIAlertController(title: "No Internet", message: "Fresh data not downloaded ", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        })
    }
    func internetDisconnected(){
        let alert = UIAlertController(title: "No Internet", message: "Fresh data not downloaded ", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    @objc func didSaveContext(notification: Notification) {
        DispatchQueue.main.async(execute: { () -> Void in
             NotificationCenter.default.post(name: NSNotification.Name(rawValue: "getData"), object: nil, userInfo: nil)
            self.dataDownloadedFromServer()
            if self.isPullToRefresh == true{
                self.isPullToRefresh = false
                MBProgressHUD.hide(for: self.view, animated: true)
            }
        })
    }
    @objc func downloadDataOnPullToRefresh() {
        if self.isInternetAwailable == false{
            let alert = UIAlertController(title: "No Internet", message: "Fresh data can not be downloaded ", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        DispatchQueue.main.async(execute: { () -> Void in
            
            let alert = UIAlertController(title: "Do you want to download data?", message: "", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { (x) in
                MBProgressHUD.showAdded(to: self.view, animated: true)
                self.isPullToRefresh = true
                Server.sharedInstance.downloadData()
                DispatchQueue.main.async {
                    self.treeView?.refreshControl?.endRefreshing()
                }
            }))
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: { (x) in
                DispatchQueue.main.async {
                    self.treeView?.refreshControl?.endRefreshing()
                }
                
            }))
            self.present(alert, animated: true, completion: nil)
        })
       
    }
    @objc func dataDownloadedFromServer(){
        do{
           displayArray.removeAll()
           rankingArray .removeAll()
           categoryDict = nil
           rankingDict = nil
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let managedContext = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<ECategory>(entityName: "ECategory")
            let results = try managedContext.fetch(request)
            displayArray = Server.sharedInstance.getDisplayCategoryArray(array: results)
            let rankRequest = NSFetchRequest<ERanking>(entityName: "ERanking")
            rankingArray = try managedContext.fetch(rankRequest)
            if displayArray.count <= 0 && rankingArray.count <= 0{
                MBProgressHUD.showAdded(to: self.view, animated: true)
               
                Server.sharedInstance.downloadData()
                return
            }
            displayData()
        }
        catch{
            print("Error ")
        }
    }
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
       self.displayData()
       
    }
    func displayData(){
        DispatchQueue.main.async(execute: { () -> Void in
            if self.treeView != nil{
               self.treeView?.removeFromSuperview()
               self.treeView = nil
            }
            let nodes = TreeNodeHelper.sharedInstance.getSortedNodes(self.displayArray , defaultExpandLevel: 0)
  
            let tableview: TreeTableView = TreeTableView(frame: CGRect(x: 0, y: 20, width: self.view.frame.width, height: self.view.frame.height-20), withData: nodes, withRank: self.rankingArray)
            tableview.tableFooterView = UIView()
            self.view.addSubview(tableview)
            self.treeView = tableview
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func categoryTapped(notification:Notification)
    {
        let categoryLevel = notification.object as! [Int]
        
        let category = Server.sharedInstance.getCategoryDict(levelArray: categoryLevel)
        categoryDict = category
        rankingDict = nil
        performSegue(withIdentifier: "productsList", sender: nil)
        
    }
    @objc func rankingTapped(notification:Notification)
    {
        let rankDict = notification.object as! ERanking
        if rankDict.isFault{
            self.dataDownloadedFromServer()
            return
        }
        rankingDict = rankDict
        categoryDict = nil
        performSegue(withIdentifier: "productsList", sender: nil)
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "productsList"{
            let productsViewController = segue.destination as! ProductsTableViewController
            if (categoryDict != nil){
                let categoryName = (categoryDict!.categoryName!)
                productsViewController.categoryID = (categoryDict?.categoryID)!
                productsViewController.title = String(describing: categoryName)
            }
            else{
                
                productsViewController.productIDList = (rankingDict?.products!)!
                productsViewController.title = rankingDict?.ranking!
            }
            
        }
    }
   
}


