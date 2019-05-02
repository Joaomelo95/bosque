//
//  ViewController.swift
//  bosque
//
//  Created by João Melo on 15/04/19.
//  Copyright © 2019 João Melo. All rights reserved.


import UIKit
import SpriteKit
import CloudKit

// Variável que localiza a área de ONG selecionada
var areaSelected: Int = 0

class ViewController: UIViewController {
    
    // Variáveis do CloudKit
    var container = CKContainer.default()
    var publicDB = CKContainer.default().publicCloudDatabase
    var savingTreeColor = ""
    var loadingTreeColor = ""
    var randomX: Double = 0.0
    var randomY: Double = 0.0
    var trees = [CKRecord]()
    
    // Variáveis do Back Button
    @IBOutlet weak var backButtonLayout: UIButton!
    @IBAction func backButtonAction(_ sender: Any) {
        if let scene = (self.mainSKView.scene as? MainScene) {
            scene.backButtonAction()
        }
    }
    
    // Variáveis para o posicionamento das árvores
    var frameSize: CGRect = CGRect()
    var xMax: Float = 0.0
    var yMax: Float = 0.0
    
    // Variável da SKView
    @IBOutlet weak var mainSKView: SKView!
    
    // Variável da câmera
    var cam: SKCameraNode?
    
    // Variável da treeSelectionView
    @IBOutlet weak var treeSelectionView: UIView!
    
    // Ajustes da treeSelectionView
    func setTreeSelectionView() {
        self.treeSelectionView.layer.cornerRadius = 15
        self.treeSelectionView.layer.masksToBounds = true
        self.treeSelectionView.alpha = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Ajustes da treeSelectionView
        self.setTreeSelectionView()
        
        // Carregar a SKScene
        let scene = SKScene(fileNamed: "Main.sks")
        scene?.scaleMode = .aspectFill
        self.mainSKView.presentScene(scene)
        
        // Inicialização para o Back Button
        if let scene = (self.mainSKView.scene as? MainScene) {
            scene.backButtonLayout = self.backButtonLayout
        }
        
        // Inicialização da câmera
        self.cam = SKCameraNode()
        self.mainSKView.scene?.camera = cam
        cam?.name = "camera"
        self.mainSKView.scene?.addChild(cam!)
        
        // Carregar as árvores
        self.loadTrees(createTree: false, lastRecord: nil, completion: { () in
            DispatchQueue.main.async {
                for tree in self.trees {
                    self.loadingTreeColor = tree["color"]!
                    self.createTree(color: self.loadingTreeColor)
                }
            }
        })
    }
    
    // Funções dos botões de árvores
    @IBAction func redTreeButton(_ sender: Any) {
        self.savingTreeColor = "red"
        self.saveTree(color: self.savingTreeColor, area: areaSelected)
        self.createTree(color: "red")
    }
    
    @IBAction func blueTreeButton(_ sender: Any) {
        self.savingTreeColor = "blue"
        self.saveTree(color: self.savingTreeColor, area: areaSelected)
        self.createTree(color: "blue")
    }
    
    @IBAction func yellowTreeButton(_ sender: Any) {
        self.savingTreeColor = "yellow"
        self.saveTree(color: self.savingTreeColor, area: areaSelected)
        self.createTree(color: "yellow")
    }
    
    @IBAction func greenTreeButton(_ sender: Any) {
        self.savingTreeColor = "green"
        self.saveTree(color: self.savingTreeColor, area: areaSelected)
        self.createTree(color: "green")
    }
    
    // Função para salvar árvores
    func saveTree(color: String, area: Int/*, position: Float, timeStamp: ?time?*/) {
        // Cria o record da árvore
        let newTree = CKRecord(recordType: "Tree")
        newTree.setValue(color, forKey: "color")
        newTree.setValue(area, forKey: "areaSelected")
        //newTree.setValue(position, forKey: //insert random number)
        //newTree.setValue(timeStamp, forKey: //insert time it was created)
        
        // Salva na cloud
        self.publicDB.save(newTree) { (record, error) in
            guard record != nil else { return }
            self.trees.append(record!)
        }
    }
    
    // Função para carregar as árvores
    func loadTrees(createTree: Bool, lastRecord: CKRecord?, completion: @escaping () -> Void) {
        let query = CKQuery(recordType: "Tree", predicate: NSPredicate(value: true))
        self.publicDB.perform(query, inZoneWith: nil) { (records, _) in
            guard let records = records else { return }
            self.trees = records
            DispatchQueue.main.async {
                if createTree {
                        print(records)
                        self.createTree(color: self.loadingTreeColor)
                }
            }
            completion()
        }
    }
    
    // Função para gerar nós
    func createTree(color: String) {
        let treeNode = SKShapeNode(rectOf: CGSize(width: 20, height: 40))
        treeNode.name = "tree"
        
        // Define a cor da árvore
        if color == "red" {
            treeNode.fillColor = SKColor.red
        } else if color == "blue" {
            treeNode.fillColor = SKColor.blue
        } else if color == "yellow" {
            treeNode.fillColor = SKColor.yellow
        } else if color == "green" {
            treeNode.fillColor = SKColor.green
        }
        
        self.randomNumber()
        treeNode.position = CGPoint(x: CGFloat(self.xMax), y: CGFloat(self.yMax))
        
        self.mainSKView.scene?.addChild(treeNode)
    }
    
    // Função para gerar números aleatórios
    func randomNumber() {
        self.xMax = Float.random(in: 0 ... Float(self.frameSize.width))
        self.yMax = Float.random(in: 0 ... Float(self.frameSize.height))
    }
}

