//
//  ViewController.swift
//  bosque
//
//  Created by João Melo on 15/04/19.
//  Copyright © 2019 João Melo. All rights reserved.


import UIKit
import CloudKit

class ViewController: UIViewController {
    
    var container = CKContainer.default()
    var publicDB = CKContainer.default().publicCloudDatabase
    var treeInsert = "new tree"
    var trees = [CKRecord]()
    var xAxis = 187.5
    var yAxis = 333.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadTrees(createTree: false)
        for tree in trees {
            self.createTree()
        }
    }
    
    @IBAction func updateTreeCount(_ sender: Any) {
        self.saveTree(string: self.treeInsert)
    }
    
    func saveTree(string: String) {
        let newTree = CKRecord(recordType: "Tree")
        newTree.setValue(string, forKey: "treeInTheWoods")
        
        self.publicDB.save(newTree) { (record, error) in
            print(error)
            guard record != nil else { return }
            print("new tree saved")
            print("trees.count na saveTree \(self.trees.count)")
            self.loadTrees(createTree: true)
        }
    }
    
    public func loadTrees(createTree: Bool) {
        print("entrou no load")
        let query = CKQuery(recordType: "Tree", predicate: NSPredicate(value: true))
        self.publicDB.perform(query, inZoneWith: nil) { (records, _) in
            guard let records = records else { return }
            self.trees = records
            DispatchQueue.main.async {
                print(self.yAxis)
                print("trees.count na loadTrees \(self.trees.count)")
                if createTree {
                    self.createTree()
                    self.yAxis += 10
                }
            }
        }
    }
    
    func createTree() {
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 40.0, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        let treeImage = CAShapeLayer()
        treeImage.path = circularPath.cgPath
        treeImage.lineWidth = 2.0
        treeImage.fillColor = UIColor.clear.cgColor
        treeImage.strokeColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        treeImage.lineCap = CAShapeLayerLineCap.round
        treeImage.position = CGPoint(x: self.xAxis, y: self.yAxis)
        self.view.layer.addSublayer(treeImage)
    }
}

