//
//  TreeNode.swift
//  TreeTableVIewWithSwift
//
//  Created by Mohd Farhan Khan on 7/18/18.
//  Copyright © 2018 Mohd Farhan Khan. All rights reserved.
//

import Foundation

open class TreeNode {
    static let NODE_TYPE_G: Int = 0
    static let NODE_TYPE_N: Int = 1
    var type: Int?
    var desc: Int?
    var id: String?
    var pId: String?
    var name: String?
    var levelArray: [Int]?
    var level: Int?
    var isExpand: Bool = false
    var icon: String?
    var children: [TreeNode] = []
    var parent: TreeNode?
    
    init (prCount: Int?, id:String? , pId: String? , name: String?, levelArray: [Int]?) {
        self.desc = prCount
        self.id = id
        self.pId = pId
        self.name = name
        self.levelArray = levelArray
    }
    func isRoot() -> Bool{
        return parent == nil
    }
    func isParentExpand() -> Bool {
        if parent == nil {
            return false
        }
        return (parent?.isExpand)!
    }
    func isLeaf() -> Bool {
        return children.count == 0
    }
    func getLevel() -> Int {
        return parent == nil ? 0 : (parent?.getLevel())!+1
    }
    func setExpand(_ isExpand: Bool) {
        self.isExpand = isExpand
        if !isExpand {
            for i in 0 ..< children.count {
                children[i].setExpand(isExpand)
            }
        }
    }
    
}
