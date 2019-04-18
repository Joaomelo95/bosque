//
//  ViewController.swift
//  bosque
//
//  Created by João Melo on 15/04/19.
//  Copyright © 2019 João Melo. All rights reserved.
//
//O QUE TEM QUE FAZER:
// 1. ENVIAR QUE UM CLIQUE NO BOTÃO FOI DADO
// 2. ATUALIZAR O DADO NA CLOUD
// 3. FAZER O FETCH DO NOVO NÚMERO TOTAL
// 4. GERAR OBJETOS DE ACORDO COM O NÚMERO TOTAL EM LOCAIS DIFERENTES DA TELA
// ??
// PROFIT


import UIKit
import CloudKit

class ViewController: UIViewController {

    var container = CKContainer.default()
    var publicDB = CKContainer.default().publicCloudDatabase
    var treeInsert = "new tree"
    var trees = [CKRecord]()
    let treeImage = CAShapeLayer()
    var xAxis = 187.5
    var yAxis = 333.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadTrees()
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
            self.loadTrees()
        }
    }
    
    func loadTrees() {
        print("entrou no load")
        let query = CKQuery(recordType: "Tree", predicate: NSPredicate(value: true))
        self.publicDB.perform(query, inZoneWith: nil) { (records, _) in
            guard let records = records else { return }
            self.trees = records
            DispatchQueue.main.async {
                print(self.yAxis)
                print("trees.count na loadTrees \(self.trees.count)")
                for tree in self.trees {
                    self.createTree()
                    self.yAxis += 10
                }
            }
        }
    }
    
    func createTree() {
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 40.0, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        self.treeImage.path = circularPath.cgPath
        self.treeImage.lineWidth = 2.0
        self.treeImage.fillColor = UIColor.clear.cgColor
        self.treeImage.strokeColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        self.treeImage.lineCap = CAShapeLayerLineCap.round
        self.treeImage.position = CGPoint(x: self.xAxis, y: self.yAxis)
        self.view.layer.addSublayer(treeImage)
    }
}

