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
var areaSelectedGlobal: Int = 0

class ViewController: UIViewController {
    
    //////////////////////////////////////////
    var countDelete = 0
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBAction func deleteButtonAction(_ sender: Any) {
        let querry = CKQuery(recordType: "Tree", predicate: NSPredicate(value: true))
        self.publicDB.perform(querry, inZoneWith: nil) { (records, error) in
            if error == nil {
                self.countDelete = (records?.count)!
                for record in records! {
                    self.publicDB.delete(withRecordID: record.recordID, completionHandler: { (recordId, error) in
                        if error == nil {
                            print("dados deletados")
                            self.countDelete -= 1
                            if self.countDelete == 0 {
                                self.trees = []
                                print("cabô")
                            }
                        }
                    })
                }
            }
        }
    }
    //////////////////////////////////////////
    
    // Variáveis do CloudKit
    var container = CKContainer.default()
    var publicDB = CKContainer.default().publicCloudDatabase
    var savingTreeColor = ""
    var loadingTreeColor = ""
    var loadingTreePositionX: Double = 0.0
    var loadingTreePositionY: Double = 0.0
    var loadingAreaSelected: Int = 0
    var trees = [CKRecord]()
    
    // Variáveis do Back Button
    @IBOutlet weak var backButtonLayout: UIButton!
    @IBAction func backButtonAction(_ sender: Any) {
        if let scene = (self.mainSKView.scene as? MainScene) {
            scene.backButtonAction()
        }
    }
    
    // Variáveis das infos das ONGs
    @IBOutlet weak var ONGIconImageView: UIImageView!
    @IBOutlet weak var ONGDescriptionLabel: UILabel!
    @IBOutlet weak var ONGAboutButtonLayout: UIButton!
    
    // Ajustes das infos das ONGs
    func setONGInfos() {
        self.ONGIconImageView.alpha = 0
        self.ONGDescriptionLabel.alpha = 0
        self.ONGAboutButtonLayout.alpha = 0
    }
    
    // Função do "Veja mais" das ONGs
    @IBAction func ONGAboutButton(_ sender: Any) {
        if areaSelectedGlobal == 1 {
            print("funfou area 1")
        } else if areaSelectedGlobal == 2 {
            print("funfou area 2")
        }
    }
    
    // Variáveis para o posicionamento das árvores
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
        // Ajustes da treeSelectionView
        self.setTreeSelectionView()
        
        // Ajustes das infos das ONGs
        self.setONGInfos()
        
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
        self.loadTrees(createTree: false, completion: { () in
            DispatchQueue.main.async {
                for tree in self.trees {
                    self.loadingTreeColor = tree["color"]!
                    self.loadingTreePositionX = tree["positionX"]!
                    self.loadingTreePositionY = tree["positionY"]!
                    areaSelectedGlobal = tree["areaSelected"]!
                    if let scene = (self.mainSKView.scene as? MainScene) {
                        scene.createTree(color: self.loadingTreeColor, x: self.loadingTreePositionX, y: self.loadingTreePositionY, area: areaSelectedGlobal)
                    }
                }
            }
        })
    }
    
    // Função para criar alertas
    func createAlert(treeColor: String) {
        //Cria o alerta
        let alert = UIAlertController(title: "Você escolheu \(treeColor)!\n\n\n\n\n\n\n", message: "Para inserir, pague ou veja um anúncio", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Pagar", style: .default, handler: { action in
            self.savingTreeColor = treeColor
            if let scene = (self.mainSKView.scene as? MainScene) {
                scene.randomNumber(areaSelected: areaSelectedGlobal)
                scene.createTree(color: treeColor, x: Double(scene.xMax), y: Double(scene.yMax), area: areaSelectedGlobal)
                self.saveTree(color: self.savingTreeColor, area: areaSelectedGlobal, positionX: scene.xMax, positionY: scene.yMax)
            }
        }))
        alert.addAction(UIAlertAction(title: "Anúncio", style: .default, handler: {action in
            self.savingTreeColor = treeColor
            if let scene = (self.mainSKView.scene as? MainScene) {
                scene.randomNumber(areaSelected: areaSelectedGlobal)
                scene.createTree(color: treeColor, x: Double(scene.xMax), y: Double(scene.yMax), area: areaSelectedGlobal)
                self.saveTree(color: self.savingTreeColor, area: areaSelectedGlobal, positionX: scene.xMax, positionY: scene.yMax)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .destructive, handler: {action in
            
        }))
        
        // Adicionar imagem do alerta
        let imageAlert = UIImageView(image: UIImage(named: treeColor))
        alert.view.addSubview(imageAlert)
        imageAlert.translatesAutoresizingMaskIntoConstraints = false
        alert.view.addConstraint(NSLayoutConstraint(item: imageAlert, attribute: .centerX, relatedBy: .equal, toItem: alert.view, attribute: .centerX, multiplier: 1, constant: 0))
        alert.view.addConstraint(NSLayoutConstraint(item: imageAlert, attribute: .centerY, relatedBy: .equal, toItem: alert.view, attribute: .centerY, multiplier: 1, constant: -64))
        alert.view.addConstraint(NSLayoutConstraint(item: imageAlert, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 64.0))
        alert.view.addConstraint(NSLayoutConstraint(item: imageAlert, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 64.0))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // Funções dos botões de árvores
    
    
    @IBAction func redTreeButton(_ sender: Any) {
        self.createAlert(treeColor: "red")
    }
    
    @IBAction func blueTreeButton(_ sender: Any) {
        self.createAlert(treeColor: "blue")
    }
    
    @IBAction func yellowTreeButton(_ sender: Any) {
        self.createAlert(treeColor: "yellow")
    }
    
    @IBAction func greenTreeButton(_ sender: Any) {
        self.createAlert(treeColor: "green")
    }
    
    // Função para salvar árvores
    func saveTree(color: String, area: Int, positionX: Float, positionY: Float/*timeStamp: ?time?*/) {
        // Cria o record da árvore
        let newTree = CKRecord(recordType: "Tree")
        newTree.setValue(color, forKey: "color")
        newTree.setValue(area, forKey: "areaSelected")
        newTree.setValue(positionX, forKey: "positionX")
        newTree.setValue(positionY, forKey: "positionY")
        //newTree.setValue(timeStamp, forKey: //insert time it was created)
        
        // Salva na cloud
        self.publicDB.save(newTree) { (record, error) in
            guard record != nil else { return }
            self.trees.append(record!)
        }
    }
    
    // Função para carregar as árvores
    func loadTrees(createTree: Bool, completion: @escaping () -> Void) {
        let query = CKQuery(recordType: "Tree", predicate: NSPredicate(value: true))
        self.publicDB.perform(query, inZoneWith: nil) { (records, _) in
            guard let records = records else { return }
            self.trees = records
            DispatchQueue.main.async {
                if createTree {
                    print(records)
                    if let scene = (self.mainSKView.scene as? MainScene) {
                        scene.randomNumber(areaSelected: areaSelectedGlobal)
                        scene.createTree(color: self.loadingTreeColor, x: self.loadingTreePositionX, y: self.loadingTreePositionY, area: areaSelectedGlobal)
                    }
                }
            }
            completion()
        }
    }
}

