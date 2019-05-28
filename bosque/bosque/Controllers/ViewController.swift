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
        UserDefaults.standard.removeObject(forKey: "treesPlanted")
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
    
    
    // SKView das nuvens
    var cloudScene:cloudsScene?
    var cloudTimer = Timer()
    var cloudSelector: Int = 0
    
    // Função para gerar nuvens
    @objc func formClouds() {
        if let mainScene = self.mainSKView.scene as? MainScene {
            self.cloudScene = mainScene.cloudSKNode
        }
        self.cloudSelector = Int.random(in: 1 ... 6)
        if let cloudScene = self.cloudScene {
            if self.cloudSelector == 1 {
                cloudScene.moveClouds(cloudName: "nuvem1", width: 270, height: 96, speed: 40)
            } else if self.cloudSelector == 2 {
                cloudScene.moveClouds(cloudName: "nuvem2", width: 306, height: 106, speed: 40)
            } else if self.cloudSelector == 3 {
                cloudScene.moveClouds(cloudName: "nuvem3", width: 176, height: 80, speed: 40)
            } else if self.cloudSelector == 4 {
                cloudScene.moveClouds(cloudName: "nuvem4", width: 784, height: 358, speed: 30)
            } else if self.cloudSelector == 5 {
                cloudScene.moveClouds(cloudName: "nuvem5", width: 1151, height: 398, speed: 20)
            } else if self.cloudSelector == 6 {
                cloudScene.moveClouds(cloudName: "nuvem6", width: 1406, height: 504, speed: 20)
            }
        }
    }
    
    func randomCloud() {
        self.cloudTimer = Timer.scheduledTimer(timeInterval: 7, target: self, selector: Selector("formClouds"), userInfo: nil, repeats: true)
    }
    
    // Variáveis das infos das ONGs
    @IBOutlet weak var ONGInfoView: UIView!
    @IBOutlet weak var ONGIconImageView: UIImageView!
    @IBOutlet weak var ONGDescriptionLabel: UILabel!
    @IBOutlet weak var ONGAboutButtonLayout: UIButton!
    
    // Ajustes das infos das ONGs
    func setONGInfos() {
        self.ONGInfoView.alpha = 0
        self.ONGIconImageView.alpha = 0
        self.ONGDescriptionLabel.alpha = 0
        self.ONGAboutButtonLayout.alpha = 0
    }
    
    // Checa conexão de internet para realizar segue
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if Reachability.isConnectedToNetwork() {
            return true
        } else {
            let alertNoConnection = UIAlertController(title: "Você não está conectado à internet!", message: "Conecte-se para poder acessar o bosque!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            }))
            self.present(alertNoConnection, animated: true, completion: nil)
            return false
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
    
    // Ajustes das views adjacentes
    func setGraphicViews() {
        self.ONGInfoView.layer.cornerRadius = 15
        self.ONGInfoView.layer.masksToBounds = true
        
        self.treeSelectionView.layer.cornerRadius = 15
        self.treeSelectionView.layer.masksToBounds = true
        self.treeSelectionView.alpha = 0
        
        self.treesPlantedView.layer.cornerRadius = 15
        self.treesPlantedView.layer.masksToBounds = true
    }
    
    ////////////////////////////////////////////////////////////////////////////////////
    // VER A UTILIDADE DO BLUR NO FUTURO
    
    // Variáveis dos efeitos visuais
    @IBOutlet weak var visualEffectsView: UIVisualEffectView!
    var effect: UIVisualEffect!
    
    // Ajustes da blurView
    func setBlurView() {
        self.visualEffectsView.alpha = 0
    }
    
    // Função de animação do blurView
    func animateBlurView() {
        self.visualEffectsView.alpha = 1
        self.visualEffectsView.effect = self.effect
    }
    
    // Função que desfaz animações do blurView
    func reverseBlurView() {
        UIView.animate(withDuration: 0.1) {
            self.visualEffectsView.effect = nil
            self.visualEffectsView.alpha = 0
        }
    }
    ////////////////////////////////////////////////////////////////////////////////////
    
    // Função do alerta de agradecimento
    func thankUAlert(areaSelected: Int) {
        if areaSelected == 1 {
            let alertThankU = UIAlertController(title: "\n\n\n\n\n\n\n", message: "A WWF agradece a sua ajuda!", preferredStyle: .alert)
            alertThankU.addAction(UIAlertAction(title: "Continuar", style: .default, handler: { action in
            }))
            self.present(alertThankU, animated: false, completion: nil)
            
            let imageAlert = UIImageView(image: UIImage(named: "ong1"))
            alertThankU.view.addSubview(imageAlert)
            imageAlert.translatesAutoresizingMaskIntoConstraints = false
            alertThankU.view.addConstraint(NSLayoutConstraint(item: imageAlert, attribute: .centerX, relatedBy: .equal, toItem: alertThankU.view, attribute: .centerX, multiplier: 1, constant: 0))
            alertThankU.view.addConstraint(NSLayoutConstraint(item: imageAlert, attribute: .centerY, relatedBy: .equal, toItem: alertThankU.view, attribute: .centerY, multiplier: 1, constant: -40))
            alertThankU.view.addConstraint(NSLayoutConstraint(item: imageAlert, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 100.0))
            alertThankU.view.addConstraint(NSLayoutConstraint(item: imageAlert, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 148.0))
        } else if areaSelected == 2 {
            let alertThankU = UIAlertController(title: "\n\n\n\n\n\n\n", message: "A Unicef agradece a sua ajuda!", preferredStyle: .alert)
            alertThankU.addAction(UIAlertAction(title: "Continuar", style: .default, handler: { action in
            }))
            self.present(alertThankU, animated: false, completion: nil)
            
            let imageAlert = UIImageView(image: UIImage(named: "ong2"))
            alertThankU.view.addSubview(imageAlert)
            imageAlert.translatesAutoresizingMaskIntoConstraints = false
            alertThankU.view.addConstraint(NSLayoutConstraint(item: imageAlert, attribute: .centerX, relatedBy: .equal, toItem: alertThankU.view, attribute: .centerX, multiplier: 1, constant: 0))
            alertThankU.view.addConstraint(NSLayoutConstraint(item: imageAlert, attribute: .centerY, relatedBy: .equal, toItem: alertThankU.view, attribute: .centerY, multiplier: 1, constant: -40))
            alertThankU.view.addConstraint(NSLayoutConstraint(item: imageAlert, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 150.0))
            alertThankU.view.addConstraint(NSLayoutConstraint(item: imageAlert, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 138.0))
        }
    }
    
    // Variáveis do Google Ad Mob
    var rewardBasedVideoInArea1: GADRewardBasedVideoAd?
    var rewardBasedVideoInArea2: GADRewardBasedVideoAd?
    var treeColorForAd = ""
    
    // Variável que indica se viu o vídeo
    var canBeRewarded = false
    
    // Função que configura a premiação do anúncio
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didRewardUserWith reward: GADAdReward) {
        print("Reward received with currency: \(reward.type), amount \(reward.amount).")
        self.savingTreeColor = self.treeColorForAd
        if let scene = (self.mainSKView.scene as? MainScene) {
            scene.randomNumber(areaSelected: areaSelectedGlobal)
            scene.createTree(color: self.treeColorForAd, x: Double(scene.xMax), y: Double(scene.yMax), area: areaSelectedGlobal, new: true, animate: false)
            self.saveTree(color: self.savingTreeColor, area: areaSelectedGlobal, positionX: scene.xMax, positionY: scene.yMax)
            self.savingTreesPlantedToUserDefaults()
            self.canBeRewarded = true
        }
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // Função que recarrega os vídeos
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        GADRewardBasedVideoAd.sharedInstance().load(GADRequest(), withAdUnitID: "ca-app-pub-3940256099942544/1712485313")
        
        // FIXME: COLOCAR O OUTRO AD TB
        
        if canBeRewarded {
            self.thankUAlert(areaSelected: areaSelectedGlobal)
            self.canBeRewarded = false
        }
        print("vídeos recarregados")
    }
    /////////////////////////////////////////////////////////////////////////////////
    
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
        self.ONGInfoView.alpha = 0
        self.ONGIconImageView.alpha = 0
        self.ONGDescriptionLabel.alpha = 0
        self.ONGAboutButtonLayout.alpha = 0
        self.savingTreesPlantedToUserDefaults()
        self.generateTrees(treeColor: self.savingTreeColor)
    }
    
    // Função que checa se está conectado no iCloud
    func isICloudContainerAvailable() -> Bool
    {
        if FileManager.default.ubiquityIdentityToken != nil {return true}
        else {return false}
    }
    
    // Configurações de quantas árvores o usuário plantou
    @IBOutlet weak var treesPlantedView: UIView!
    @IBOutlet weak var treesPlantedLabel: UILabel!
    @IBOutlet weak var treesPlantedIcon: UIImageView!
    
    func savingTreesPlantedToUserDefaults() {
        var plantedTrees = UserDefaults.standard.integer(forKey: "treesPlanted")
        plantedTrees += 1
        self.treesPlantedLabel.text = "\(plantedTrees)"
        UserDefaults.standard.set(plantedTrees, forKey: "treesPlanted")
        print(UserDefaults.standard.integer(forKey: "treesPlanted"))
    }
    
    // viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.reload()
        self.randomCloud()
        self.formClouds()
    }
    
    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        // Ajustes dos efeitos visuais
        effect = visualEffectsView.effect
        visualEffectsView.effect = nil
        
        // Ajustes da blurView
        self.setBlurView()
        
        // Verifica a conexão de rede
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
        }else{
            print("Internet Connection not Available!")
            
            self.visualEffectsView.alpha = 1
            self.visualEffectsView.effect = self.effect
            
            DispatchQueue.main.async {
                let alertNoConnection = UIAlertController(title: "Você não está conectado à internet!", message: "Conecte-se para poder acessar o bosque!", preferredStyle: .alert)
                alertNoConnection.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                    UIControl().sendAction(#selector(NSXPCConnection.suspend), to: UIApplication.shared, for: nil)
                }))
                self.present(alertNoConnection, animated: true, completion: nil)
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
        self.setGraphicViews()
        
        // Ajustes das infos das ONGs
        self.setONGInfos()
        
        // Carregar a SKScene
        let scene = SKScene(fileNamed: "Main.sks")
        scene?.scaleMode = .aspectFill
        self.mainSKView.showsPhysics = true
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
        
        // Carrega a quantidade de árvores plantadas localmente
        var plantedTrees = UserDefaults.standard.integer(forKey: "treesPlanted")
        self.treesPlantedLabel.text = "\(plantedTrees)"
        
        // Carregar as árvores
        self.loadTrees(createTree: false, completion: { () in
            DispatchQueue.main.async {
                for tree in self.trees {
                    self.loadingTreeColor = tree["color"]!
                    self.loadingTreePositionX = tree["positionX"]!
                    self.loadingTreePositionY = tree["positionY"]!
                    areaSelectedGlobal = tree["areaSelected"]!
                    if let scene = (self.mainSKView.scene as? MainScene) {
                        scene.createTree(color: self.loadingTreeColor, x: self.loadingTreePositionX, y: self.loadingTreePositionY, area: areaSelectedGlobal, new: false, animate: true)
                    }
                }
            }
        })
    }
    
    // Função para gerar árvores na tela
    func generateTrees(treeColor: String) {
        if let scene = (self.mainSKView.scene as? MainScene) {
            scene.randomNumber(areaSelected: areaSelectedGlobal)
            scene.createTree(color: treeColor, x: Double(scene.xMax), y: Double(scene.yMax), area: areaSelectedGlobal, new: true, animate: false)
            self.saveTree(color: self.savingTreeColor, area: areaSelectedGlobal, positionX: scene.xMax, positionY: scene.yMax)
            
            self.thankUAlert(areaSelected: areaSelectedGlobal)
        }

    }
    
    // Configurações para só mostrar o alerta quando os vídeos estiverem carregados
    var timer = Timer()
    var adIsLoaded = false
    
    // Configurações do indicador de carregamento
    var activityIndicatorContainer: UIView!
    var activityIndicator: UIActivityIndicatorView!
    func setActivityIndicator() {
        // Configurar o containerView de background para o indicador
        activityIndicatorContainer = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        activityIndicatorContainer.center.x = self.view.frame.midX
        activityIndicatorContainer.center.y = self.view.frame.midY
        activityIndicatorContainer.backgroundColor = UIColor.black
        activityIndicatorContainer.alpha = 0.8
        activityIndicatorContainer.layer.cornerRadius = 10

        // Configurar o indicador de atividade
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorContainer.addSubview(activityIndicator)
        self.view.addSubview(activityIndicatorContainer)

        // Constraints
        activityIndicator.centerXAnchor.constraint(equalTo: activityIndicatorContainer.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: activityIndicatorContainer.centerYAnchor).isActive = true
    }
    
    // Função que mostra o indicador de carregamento
    func showActivityIndicator(show: Bool) {
        if show {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
            activityIndicatorContainer.removeFromSuperview()
        }
    }
    
    // Função para checar se os anúncios estão carregados
    @objc func checkIfIsLoaded() {
        print(self.adIsLoaded)
        if adIsLoaded == false {
            self.showActivityIndicator(show: true)
            if areaSelectedGlobal == 1 {
                if rewardBasedVideoInArea1!.isReady {
                    self.adIsLoaded = true
                }
            } else if areaSelectedGlobal == 2 {
                if rewardBasedVideoInArea2!.isReady {
                    self.adIsLoaded = true
                }
            }
        } else {
            self.showActivityIndicator(show: false)
            timer.invalidate()
            self.insertAlert(alert: self.alert)
        }
    }
    
    // Função para inserir o alerta na tela
    func insertAlert(alert: UIAlertController) {
        self.present(alert, animated: true, completion: nil)
    }
    
    // Cria o alerta
    var alert = UIAlertController()
    
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
        
        self.alert = UIAlertController(title: "Você escolheu \(treeName)!\n\n\n\n\n\n\n", message: "Para plantar, compre ou veja um anúncio", preferredStyle: .alert)
        
        self.alert.addAction(UIAlertAction(title: "Ver anúncio", style: .default, handler: { action in
            // Testa se está conectado na internet
            if Reachability.isConnectedToNetwork() && self.isICloudContainerAvailable() {
                // Quem anúncio vai ser mostrado
                if areaSelected == 1 {
                    if self.rewardBasedVideoInArea1?.isReady == true {
                        self.rewardBasedVideoInArea1?.present(fromRootViewController: self)
                        print("anúncio da area 1")
                        self.ONGInfoView.alpha = 0
                        self.ONGIconImageView.alpha = 0
                        self.ONGDescriptionLabel.alpha = 0
                        self.ONGAboutButtonLayout.alpha = 0
                        self.rewardBasedVideoAdDidClose(self.rewardBasedVideoInArea1!)
                    }
                } else if areaSelected == 2 {
                    if self.rewardBasedVideoInArea2?.isReady == true {
                        self.rewardBasedVideoInArea2?.present(fromRootViewController: self)
                        print("anúncio da area 2")
                        self.ONGInfoView.alpha = 0
                        self.ONGIconImageView.alpha = 0
                        self.ONGDescriptionLabel.alpha = 0
                        self.ONGAboutButtonLayout.alpha = 0
                        self.rewardBasedVideoAdDidClose(self.rewardBasedVideoInArea2!)
                    }
                }
            } else if !Reachability.isConnectedToNetwork() {
                let alertNoConnection = UIAlertController(title: "Você não está conectado à internet!", message: "Conecte-se para poder acessar o bosque!", preferredStyle: .alert)
                alertNoConnection.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                    
                }))
                self.present(alertNoConnection, animated: true, completion: nil)
            } else if Reachability.isConnectedToNetwork() && !self.isICloudContainerAvailable() {
                let alertNoConnection = UIAlertController(title: "Você não está conectado ao iCloud", message: "Conecte-se para poder acessar o bosque!", preferredStyle: .alert)
                alertNoConnection.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                    
                }))
                self.present(alertNoConnection, animated: true, completion: nil)
            }
        }))
        
        self.alert.addAction(UIAlertAction(title: "Comprar", style: .default, handler: { action in
            // Testa se está conectado na internet
            if Reachability.isConnectedToNetwork() && self.isICloudContainerAvailable() {
                if areaSelectedGlobal == 1 {
                    // Define a árvore e gera o pedido de compra
                    if treeColor == "red" {
                        // ALTERAR OS PRODUTOS!!
                        self.savingTreeColor = treeColor
                        self.product = self.products[4]
                        BosqueProducts.store.buyProduct(self.product)
                    } else if treeColor == "blue" {
                        // ALTERAR OS PRODUTOS!!
                        self.savingTreeColor = treeColor
                        self.product = self.products[0]
                        BosqueProducts.store.buyProduct(self.product)
                    } else if treeColor == "yellow" {
                        // ALTERAR OS PRODUTOS!!
                        self.savingTreeColor = treeColor
                        self.product = self.products[6]
                        BosqueProducts.store.buyProduct(self.product)
                    } else if treeColor == "green" {
                        // ALTERAR OS PRODUTOS!!
                        self.savingTreeColor = treeColor
                        self.product = self.products[2]
                        BosqueProducts.store.buyProduct(self.product)
                    }
                } else if areaSelectedGlobal == 2 {
                    if treeColor == "red" {
                        // ALTERAR OS PRODUTOS!!
                        self.savingTreeColor = treeColor
                        self.product = self.products[5]
                        BosqueProducts.store.buyProduct(self.product)
                    } else if treeColor == "blue" {
                        // ALTERAR OS PRODUTOS!!
                        self.savingTreeColor = treeColor
                        self.product = self.products[1]
                        BosqueProducts.store.buyProduct(self.product)
                    } else if treeColor == "yellow" {
                        // ALTERAR OS PRODUTOS!!
                        self.savingTreeColor = treeColor
                        self.product = self.products[7]
                        BosqueProducts.store.buyProduct(self.product)
                    } else if treeColor == "green" {
                        // ALTERAR OS PRODUTOS!!
                        self.savingTreeColor = treeColor
                        self.product = self.products[3]
                        BosqueProducts.store.buyProduct(self.product)
                    }
                }
            } else if !Reachability.isConnectedToNetwork() {
                let alertNoConnection = UIAlertController(title: "Você não está conectado à internet!", message: "Conecte-se para poder acessar o bosque!", preferredStyle: .alert)
                alertNoConnection.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                    
                }))
                self.present(alertNoConnection, animated: true, completion: nil)
            } else if Reachability.isConnectedToNetwork() && !self.isICloudContainerAvailable() {
                let alertNoConnection = UIAlertController(title: "Você não está conectado ao iCloud", message: "Conecte-se para poder acessar o bosque!", preferredStyle: .alert)
                alertNoConnection.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                    
                }))
                self.present(alertNoConnection, animated: true, completion: nil)
            }
        }))
        
        self.alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { action in
        }))
        
        // Adicionar imagem do alerta
        let imageAlert = UIImageView(image: UIImage(named: treeAlertImageName))
        self.alert.view.addSubview(imageAlert)
        imageAlert.translatesAutoresizingMaskIntoConstraints = false
        self.alert.view.addConstraint(NSLayoutConstraint(item: imageAlert, attribute: .centerX, relatedBy: .equal, toItem: self.alert.view, attribute: .centerX, multiplier: 1, constant: 0))
        self.alert.view.addConstraint(NSLayoutConstraint(item: imageAlert, attribute: .centerY, relatedBy: .equal, toItem: self.alert.view, attribute: .centerY, multiplier: 1, constant: -64))
        self.alert.view.addConstraint(NSLayoutConstraint(item: imageAlert, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 64.0))
        self.alert.view.addConstraint(NSLayoutConstraint(item: imageAlert, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 64.0))
        
        // Coloca o indicador de carregamento na tela
        if adIsLoaded == false {
            self.setActivityIndicator()
        }
        
        // Roda o timer
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: Selector("checkIfIsLoaded"), userInfo: nil, repeats: true)
    }
    
    // Funções dos botões de árvores
    @IBAction func redTreeButton(_ sender: Any) {
        self.treeColorForAd = "red"
        self.createAlert(treeColor: "red", areaSelected: areaSelectedGlobal)
        if let scene = (self.mainSKView.scene as? MainScene) {
            scene.removeLabelAction()
        }
    }
    
    @IBAction func blueTreeButton(_ sender: Any) {
        self.treeColorForAd = "blue"
        self.createAlert(treeColor: "blue", areaSelected: areaSelectedGlobal)
        if let scene = (self.mainSKView.scene as? MainScene) {
            scene.removeLabelAction()
        }
    }
    
    @IBAction func yellowTreeButton(_ sender: Any) {
        self.treeColorForAd = "yellow"
        self.createAlert(treeColor: "yellow", areaSelected: areaSelectedGlobal)
        if let scene = (self.mainSKView.scene as? MainScene) {
            scene.removeLabelAction()
        }
    }
    
    @IBAction func greenTreeButton(_ sender: Any) {
        self.treeColorForAd = "green"
        self.createAlert(treeColor: "green", areaSelected: areaSelectedGlobal)
        if let scene = (self.mainSKView.scene as? MainScene) {
            scene.removeLabelAction()
        }
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
        
        // Salva na cloud
        self.publicDB.save(newTree) { (record, error) in
            print(error)
            guard record != nil else { return }
            self.trees.append(record!)
            print("salvou na cloud")
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
                        scene.createTree(color: self.loadingTreeColor, x: self.loadingTreePositionX, y: self.loadingTreePositionY, area: areaSelectedGlobal, new: false, animate: false)
                    }
                }
            }
            completion()
        }
    }
}

