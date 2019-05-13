//
//  ViewController.swift
//  bosque
//
//  Created by João Melo on 15/04/19.
//  Copyright © 2019 João Melo. All rights reserved.


import UIKit
import SpriteKit
import CloudKit
import GoogleMobileAds
import StoreKit

// Variável que localiza a área de ONG selecionada
var areaSelectedGlobal: Int = 0

class ViewController: UIViewController, GADRewardBasedVideoAdDelegate {
    
    ////////////////////////////////////////////////////////////////////
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
    ////////////////////////////////////////////////////////////////////
    
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
    
    // Botão do "Veja mais" das ONGs
    @IBAction func ONGAboutButton(_ sender: Any) {
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
    
    // Variáveis dos efeitos visuais
    @IBOutlet weak var visualEffectsView: UIVisualEffectView!
    var effect: UIVisualEffect!
    
    
    // Variáveis da greetingsView
    @IBOutlet weak var greetingsView: UIView!
    @IBOutlet weak var greetingsImgView: UIImageView!
    @IBOutlet weak var ONGNameGreetingsView: UILabel!
    @IBAction func continueGreetingsButton(_ sender: Any) {
        self.reverseAnimateGreetingsView()
    }
    
    // Ajustes da greetingsView
    func setGreetingsView() {
        self.greetingsView.layer.cornerRadius = 15
        self.greetingsView.layer.masksToBounds = true
        self.greetingsView.alpha = 0
        self.visualEffectsView.alpha = 0
    }
    
    // Função de animação do greetingsView
    func animateGreetingsView() {
        self.greetingsView.transform = CGAffineTransform.init(scaleX:1.3, y: 1.3)
        self.greetingsView.alpha = 0
        
        if areaSelectedGlobal == 1 {
            self.greetingsImgView.image = UIImage(named: "ong1")
            self.ONGNameGreetingsView.text = "A WWF"
        } else if areaSelectedGlobal == 2 {
            self.greetingsImgView.image = UIImage(named: "ong2")
            self.ONGNameGreetingsView.text = "A Unicef"
        }
        
        UIView.animate(withDuration: 0.4) {
            self.visualEffectsView.alpha = 1
            self.visualEffectsView.effect = self.effect
            self.greetingsView.alpha = 1
            self.greetingsView.transform = CGAffineTransform.identity
        }
    }
    
    // Função que desfaz animações do greetingsView
    func reverseAnimateGreetingsView() {
        UIView.animate(withDuration: 0.3) {
            self.greetingsView.transform = CGAffineTransform.init(scaleX:1.3, y: 1.3)
            self.greetingsView.alpha = 0
            self.visualEffectsView.effect = nil
            self.visualEffectsView.alpha = 0
        }
    }
    
    // Variáveis do Google Ad Mob
    var rewardBasedVideoInArea1: GADRewardBasedVideoAd?
    var rewardBasedVideoInArea2: GADRewardBasedVideoAd?
    var treeColorForAd = ""
    
    // Função que configura a premiação do anúncio
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didRewardUserWith reward: GADAdReward) {
        print("Reward received with currency: \(reward.type), amount \(reward.amount).")
        self.savingTreeColor = self.treeColorForAd
        if let scene = (self.mainSKView.scene as? MainScene) {
            scene.randomNumber(areaSelected: areaSelectedGlobal)
            scene.createTree(color: self.treeColorForAd, x: Double(scene.xMax), y: Double(scene.yMax), area: areaSelectedGlobal, new: true)
            self.saveTree(color: self.savingTreeColor, area: areaSelectedGlobal, positionX: scene.xMax, positionY: scene.yMax)
            self.animateGreetingsView()
        }
    }
    
    // Função que recarrega os vídeos
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        GADRewardBasedVideoAd.sharedInstance().load(GADRequest(), withAdUnitID: "ca-app-pub-3940256099942544/1712485313")
        print("vídeos recarregados")
    }
    
    // Variável de produtos do StoreKit
    var product: SKProduct!
    var products: [SKProduct] = []
    
    // Função para encontrar os produtos
    func reload() {
        self.products = []
        BosqueProducts.store.requestProducts{ [weak self] success, products in
            guard let self = self else { return }
            if success {
                self.products = products!
                print("Produtos na array: \(self.products.count)")
            }
        }
    }
    
    // Função que realiza a notificação de compra e finaliza a compra gerando uma árvore
    @objc func handlePurchaseNotification(_ notification: Notification) {
        guard
            let productID = notification.object as? String,
            let index = products.index(where : { product -> Bool in
            product.productIdentifier == productID
        })
        else { return }
        
        self.generateTrees(treeColor: self.savingTreeColor)
    }
    
    // viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        self.reload()
    }
    
    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        // Ajustes dos efeitos visuais
        effect = visualEffectsView.effect
        visualEffectsView.effect = nil
        
        // Ajustes da greetingsView
        self.setGreetingsView()
        
        // Verifica a conexão de rede
        if Reachability.isConnectedToNetwork(){
            // DEIXA O APP ROLAR
            print("Internet Connection Available!")
        }else{
            // NÃO DEIXA O APP ROLAR
            print("Internet Connection not Available!")
            
            self.visualEffectsView.alpha = 1
            self.visualEffectsView.effect = self.effect
            
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Você não está conectado à internet!", message: "Conecte-se para poder acessar o bosque!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                    UIControl().sendAction(#selector(NSXPCConnection.suspend), to: UIApplication.shared, for: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        // Faz o request para puxar os produtos do StoreKit
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.handlePurchaseNotification(_:)), name: .IAPHelperPurchaseNotification, object: nil)
        
        // Configurações do Google Ad Mob
        rewardBasedVideoInArea1 = GADRewardBasedVideoAd.sharedInstance()
        rewardBasedVideoInArea1?.delegate = self
        
        rewardBasedVideoInArea2 = GADRewardBasedVideoAd.sharedInstance()
        rewardBasedVideoInArea2?.delegate = self
        
        // Carrega os vídeos
        rewardBasedVideoInArea1?.load(GADRequest(), withAdUnitID: "ca-app-pub-3940256099942544/1712485313")
        rewardBasedVideoInArea2?.load(GADRequest(), withAdUnitID: "ca-app-pub-3940256099942544/1712485313")
        
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
                        scene.createTree(color: self.loadingTreeColor, x: self.loadingTreePositionX, y: self.loadingTreePositionY, area: areaSelectedGlobal, new: false)
                    }
                }
            }
        })
    }
    
    // Função para gerar árvores na tela
    func generateTrees(treeColor: String) {
        if let scene = (self.mainSKView.scene as? MainScene) {
            scene.randomNumber(areaSelected: areaSelectedGlobal)
            scene.createTree(color: treeColor, x: Double(scene.xMax), y: Double(scene.yMax), area: areaSelectedGlobal, new: true)
            self.saveTree(color: self.savingTreeColor, area: areaSelectedGlobal, positionX: scene.xMax, positionY: scene.yMax)
            self.animateGreetingsView()
        }

    }
    
    // Função para criar alertas
    func createAlert(treeColor: String, areaSelected: Int) {
        // Nome da árvore
        var treeName = ""
        var treeAlertImageName = ""
        
        if treeColor == "red" {
            treeName = "o cedro"
            treeAlertImageName = "treeRed"
        } else if treeColor == "blue" {
            treeName = "a cerejeira"
            treeAlertImageName = "treeBlue"
        } else if treeColor == "yellow" {
            treeName = "o pinheiro"
            treeAlertImageName = "treeYellow"
        } else if treeColor == "green" {
            treeName = "o ipê"
            treeAlertImageName = "treeGreen"
        }
        
        // Cria o alerta
        let alert = UIAlertController(title: "Você escolheu \(treeName)!\n\n\n\n\n\n\n", message: "Para inserir, doe ou veja um anúncio", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Doar", style: .default, handler: { action in
            // Testa se está conectado na internet
            if Reachability.isConnectedToNetwork() {
                // Define a árvore e gera o pedido de compra
                if treeColor == "red" {
                    // ALTERAR OS PRODUTOS!!
                    self.savingTreeColor = treeColor
                    self.product = self.products[2]
                    BosqueProducts.store.buyProduct(self.product)
                } else if treeColor == "blue" {
                    // ALTERAR OS PRODUTOS!!
                    self.savingTreeColor = treeColor
                    self.product = self.products[0]
                    BosqueProducts.store.buyProduct(self.product)
                } else if treeColor == "yellow" {
                    // ALTERAR OS PRODUTOS!!
                    self.savingTreeColor = treeColor
                    self.product = self.products[3]
                    BosqueProducts.store.buyProduct(self.product)
                } else if treeColor == "green" {
                    // ALTERAR OS PRODUTOS!!
                    self.savingTreeColor = treeColor
                    self.product = self.products[1]
                    BosqueProducts.store.buyProduct(self.product)
                }
            } else {
                let alert = UIAlertController(title: "Você não está conectado à internet!", message: "Conecte-se para poder acessar o bosque!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Ver anúncio", style: .default, handler: { action in
            // Testa se está conectado na internet
            if Reachability.isConnectedToNetwork() {
                // Quem anúncio vai ser mostrado
                if areaSelected == 1 {
                    if self.rewardBasedVideoInArea1?.isReady == true {
                        self.rewardBasedVideoInArea1?.present(fromRootViewController: self)
                        print("anúncio da area 1")
                        self.rewardBasedVideoAdDidClose(self.rewardBasedVideoInArea1!)
                    }
                } else if areaSelected == 2 {
                    if self.rewardBasedVideoInArea2?.isReady == true {
                        self.rewardBasedVideoInArea2?.present(fromRootViewController: self)
                        print("anúncio da area 2")
                        self.rewardBasedVideoAdDidClose(self.rewardBasedVideoInArea2!)
                    }
                }
            } else {
                let alert = UIAlertController(title: "Você não está conectado à internet!", message: "Conecte-se para poder acessar o bosque!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                    
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .destructive, handler: { action in
        }))
        
        // Adicionar imagem do alerta
        let imageAlert = UIImageView(image: UIImage(named: treeAlertImageName))
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
        self.treeColorForAd = "red"
        self.createAlert(treeColor: "red", areaSelected: areaSelectedGlobal)
    }
    
    @IBAction func blueTreeButton(_ sender: Any) {
        self.treeColorForAd = "blue"
        self.createAlert(treeColor: "blue", areaSelected: areaSelectedGlobal)
    }
    
    @IBAction func yellowTreeButton(_ sender: Any) {
        self.treeColorForAd = "yellow"
        self.createAlert(treeColor: "yellow", areaSelected: areaSelectedGlobal)
    }
    
    @IBAction func greenTreeButton(_ sender: Any) {
        self.treeColorForAd = "green"
        self.createAlert(treeColor: "green", areaSelected: areaSelectedGlobal)
    }
    
    // Função para salvar árvores
    func saveTree(color: String, area: Int, positionX: Float, positionY: Float/*timeStamp: ?time?*/) {
        print("chamou a save tree")
        // Cria o record da árvore
        let newTree = CKRecord(recordType: "Tree")
        newTree.setValue(color, forKey: "color")
        newTree.setValue(area, forKey: "areaSelected")
        newTree.setValue(positionX, forKey: "positionX")
        newTree.setValue(positionY, forKey: "positionY")
        //newTree.setValue(timeStamp, forKey: //insert time it was created)
        
        ////////////////////////////////////////////////////////////////////
        // Salva na cloud
        // DESCOBRIR COMO PEDIR PERMISSÃO
        self.publicDB.save(newTree) { (record, error) in
            print(error)
            guard record != nil else { return }
            self.trees.append(record!)
            print("salvou na cloud")
        }
        ////////////////////////////////////////////////////////////////////
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
                        scene.createTree(color: self.loadingTreeColor, x: self.loadingTreePositionX, y: self.loadingTreePositionY, area: areaSelectedGlobal, new: false)
                    }
                }
            }
            completion()
        }
    }
}

