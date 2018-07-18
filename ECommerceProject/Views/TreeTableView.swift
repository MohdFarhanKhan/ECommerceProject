//
//  TreeTableView.swift
//  TreeTableVIewWithSwift
//
//  Created by Mohd Farhan Khan on 7/18/18.
//  Copyright © 2018 Mohd Farhan Khan. All rights reserved.
//

import UIKit

protocol TreeTableViewCellDelegate: NSObjectProtocol {
    func cellClick()
}

class TreeTableView: UITableView, UITableViewDataSource,UITableViewDelegate{    
    var mAllNodes: [TreeNode]?
    var mNodes: [TreeNode]?
    var rankArray: [ERanking]?
    let NODE_CELL_ID: String = "nodecell"
    init(frame: CGRect, withData data: [TreeNode], withRank: [ERanking]) {
        super.init(frame: frame, style: UITableViewStyle.plain)
        self.delegate = self
        self.dataSource = self
        mAllNodes = data
        mNodes = TreeNodeHelper.sharedInstance.filterVisibleNode(mAllNodes!)
        rankArray = withRank
        mNodes = TreeNodeHelper.sharedInstance.filterVisibleNode(mAllNodes!)
         NotificationCenter.default.addObserver(self, selector: #selector(TreeTableView.iconChanged), name: NSNotification.Name(rawValue: "iconChanged"), object: nil)
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(TreeTableView.refresh(sender:)), for: .valueChanged)
        self.refreshControl = refreshControl
       
    }
    @objc func refresh(sender:AnyObject) {
        
       NotificationCenter.default.post(name: NSNotification.Name(rawValue: "downloadDataOnPullToRefresh"), object: nil, userInfo: nil)
       
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let nib = UINib(nibName: "TreeNodeTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: NODE_CELL_ID)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: NODE_CELL_ID) as! TreeNodeTableViewCell
        if indexPath.section == 0{
        let node: TreeNode = mNodes![indexPath.row]
        cell.background.bounds.origin.x = -20.0 * CGFloat(node.getLevel())
        if node.type == TreeNode.NODE_TYPE_G {
            cell.nodeIMG.contentMode = UIViewContentMode.center
            cell.nodeIMG.image = UIImage(named: node.icon!)
        } else {
            cell.nodeIMG.image = nil
        }
           

        cell.nodeName.text = node.name
        cell.nodeDesc.text = node.desc! > 0 ? String(describing: node.desc!) : ""
        }
        else{
            cell.nodeIMG.image = nil
             cell.background.bounds.origin.x = 0
            let rankRow = rankArray![indexPath.row]
            cell.nodeName.text = rankRow.ranking
            
            cell.nodeDesc.text = rankRow.products!.count > 0 ? String(describing: rankRow.products!.count) : ""
        }
        return cell
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        if section == 0{
           return "Categorywise"
        }
        return "Rankingwise"
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            print("category")
            print(mNodes)
             return (mNodes?.count)!
        }
        print("Ranking")
         print(rankArray)
        return (rankArray?.count)!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.section == 0{
            let parentNode = mNodes![indexPath.row]
            if parentNode.desc! > 0{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "categoryTapped"), object: parentNode.levelArray, userInfo: nil)
            
            }
            if parentNode.isLeaf() {
                
            }
        }
        else{
            let rankDict = rankArray![indexPath.row]
           NotificationCenter.default.post(name: NSNotification.Name(rawValue: "rankingTapped"), object: rankDict, userInfo: nil)
        }
      
        
    }
    @objc func iconChanged(notification:Notification)
    {
        let cellTapped = notification.object as! TreeNodeTableViewCell
        let indexPath = self.indexPath(for: cellTapped)
        let parentNode = mNodes![(indexPath?.row)!]
        
        let startPosition = (indexPath?.row)!+1
        var endPosition = startPosition
        expandOrCollapse(&endPosition, node: parentNode)
            mNodes = TreeNodeHelper.sharedInstance.filterVisibleNode(mAllNodes!) //更新可见节点
            var indexPathArray :[IndexPath] = []
            var tempIndexPath: IndexPath?
            for i in startPosition ..< endPosition {
                tempIndexPath = IndexPath(row: i, section: 0)
                indexPathArray.append(tempIndexPath!)
            }
            
           if parentNode.isExpand {
                self.insertRows(at: indexPathArray, with: UITableViewRowAnimation.none)
            } else {
                self.deleteRows(at: indexPathArray, with: UITableViewRowAnimation.none)
            }
        
        self.reloadRows(at: [indexPath!], with: UITableViewRowAnimation.none)
            
       
    }
    
    func expandOrCollapse(_ count: inout Int, node: TreeNode) {
        if node.isExpand {
            closedChildNode(&count,node: node)
        } else {
            count += node.children.count
            node.setExpand(true)
        }
        
    }
  
    func closedChildNode(_ count:inout Int, node: TreeNode) {
        if node.isLeaf() {
            return
        }
        if node.isExpand {
            node.isExpand = false
            for item in node.children {
                count += 1 
                closedChildNode(&count, node: item)
            }
        } 
    }
    
}

