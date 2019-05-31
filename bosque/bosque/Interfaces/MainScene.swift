//
//  MainScene.swift
//  bosque
//
//  Created by João Melo on 29/04/19.
//  Copyright © 2019 João Melo. All rights reserved.
//

import SpriteKit

class MainScene: SKScene {
    // Variáveis para o posicionamento das árvores
    var xMax: Float = 0
    var yMax: Float = 0

    // Variáveis para definir se os nodes são clicáveis
    var area1IsTouchable = true
    var area2IsTouchable = true
    var bgAreaIsTouchable = false

    // Variável para guardar o centro da view
    var viewCenter: CGPoint = CGPoint(x: 0.0, y: 0.0)

    // Variável do Back Button
    var backButtonLayout: UIButton!

    // Variáves dos Nodes na Scene
    var cloudSKNode = cloudsScene()
    var firstAreaNode = SKNode()
    var secondAreaNode = SKNode()
    var wwfLogoNode = SKNode()
    var unicefLogoNode = SKNode()
    var bgAreaNode = SKNode()
    var area1Plantable = SKNode()
    var area2Plantable = SKNode()

    // Variáveis do onboarding
    var touchLabel: SKLabelNode?
    var touchLabelGambiarra: SKLabelNode?
    var touch2Label: SKLabelNode?
    var touch3Label: SKLabelNode?
    var touch6Label: SKLabelNode?
    var touch7Label: SKLabelNode?
    
    //variáveis trilha sonora
    var sound = SKAction.playSoundFileNamed("musicBosque.mp3", waitForCompletion: false)
    var sound2 = SKAction.playSoundFileNamed("arvoreBosque.wav", waitForCompletion: false)
    var sound3 = SKAction.playSoundFileNamed("zooms.mp3", waitForCompletion: false)

    // Função de remover labels do onboarding
    func removeLabelAction() {
        self.touch2Label?.removeAllActions()
        self.touch3Label?.removeAllActions()
        self.touchLabel?.removeAllActions()
        self.touchLabelGambiarra?.removeAllActions()
        self.touch2Label?.removeFromParent()
        self.touch3Label?.removeFromParent()
        self.touch6Label?.removeFromParent()
        self.touch7Label?.removeFromParent()
    }

    // Pinch gesture
    var previousCameraScale = CGFloat()
    let pinchGesture = UIPinchGestureRecognizer()

    @objc func pinchGestureAction(_ sender: UIPinchGestureRecognizer) {
        guard let camera = self.camera else {
            return
        }
        if sender.state == .began {
            previousCameraScale = camera.xScale
        }
        camera.setScale(previousCameraScale * 1 / sender.scale)
        self.setCameraConstraint()
    }

    func pointSubtract(pointA: CGPoint, pointB: CGPoint) -> CGPoint {
        let subtractedX = pointA.x - pointB.x
        let subtractedY = pointA.y - pointB.y
        return CGPoint(x: subtractedX, y: subtractedY)
    }

    func pointAdd(pointA: CGPoint, pointB: CGPoint) -> CGPoint {
        let addedX = pointA.x + pointB.x
        let addedY = pointA.y + pointB.y
        return CGPoint(x: addedX, y: addedY)
    }

    @objc func handlePinch(sender: UIPinchGestureRecognizer) {
        if sender.numberOfTouches == 2 {
            let locationInView = sender.location(in: self.view)
            let location = self.convertPoint(fromView: locationInView)
            if sender.state == .changed {
                let deltaScale = (sender.scale - 1.0)*2
                let convertedScale = sender.scale - deltaScale
                let newScale = camera!.xScale*convertedScale
                camera!.setScale(newScale)

                let locationAfterScale = self.convertPoint(fromView: locationInView)
                let locationDelta = pointSubtract(pointA: location, pointB: locationAfterScale)
                let newPoint = pointAdd(pointA: camera!.position, pointB: locationDelta)
                camera!.position = newPoint
                sender.scale = 1.0
            }
        }
    }

    // Cria as constraints da câmera
    func setCameraConstraint() {
        let scaledSize = CGSize(width: self.frame.size.width * camera!.xScale, height: self.frame.size.height * camera!.yScale)
        let sceneContentRect = self.calculateAccumulatedFrame()

        let xInset = min((scaledSize.width / 2) + 232, sceneContentRect.width / 2)
        let yInset = min((scaledSize.height / 2) + 130, sceneContentRect.height / 2)
        let insetContentRect = sceneContentRect.insetBy(dx: xInset, dy: yInset)

        let xRange = SKRange(lowerLimit: insetContentRect.minX, upperLimit: insetContentRect.maxX)
        let yRange = SKRange(lowerLimit: insetContentRect.minY, upperLimit: insetContentRect.maxY)
        let levelEdgeConstraint = SKConstraint.positionX(xRange, y: yRange)
        levelEdgeConstraint.referenceNode = self
        camera?.constraints = [levelEdgeConstraint]
    }

    // Pan gesture
    var lastSwipeBeginningPoint: CGPoint?
    var panRec: UIPanGestureRecognizer!

    @objc func handlePan(recognizer:UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)

        self.setCameraConstraint()

        if let view = recognizer.view {
            if camera?.xScale != 1.0 {
                camera!.position = CGPoint(x:(camera?.position.x)! - translation.x,
                                           y:((camera?.position.y)! + translation.y))
            }
        }
        recognizer.setTranslation(CGPoint.zero, in: self.view)
    }

    // MARK: didMove
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        // Configura nodes na tela
        self.firstAreaNode = self.childNode(withName: "area1")!
        self.secondAreaNode = self.childNode(withName: "area2")!
        self.wwfLogoNode = self.childNode(withName: "wwfLogo")!
        self.unicefLogoNode = self.childNode(withName: "unicefLogo")!
        self.bgAreaNode = self.childNode(withName: "bg")!
        self.area1Plantable = self.childNode(withName: "area1Plantable")!
        self.area2Plantable = self.childNode(withName: "area2Plantable")!
        self.cloudSKNode.position = CGPoint(x: self.frame.minX, y: self.frame.maxY-500)
        self.cloudSKNode.size = CGSize(width: self.frame.size.width, height: 350)
        self.addChild(cloudSKNode)
//        self.run(SKAction.repeatActionForever(SKAction.runBlock(playSound(sound: sound))))
        self.run(SKAction.repeatForever(SKAction.playSoundFileNamed("musicBosque.mp3", waitForCompletion: true)))

//        playSound(sound: sound)


        playSound(sound: sound2)



        if UserDefaults.standard.bool(forKey: "watched") == false {
            addLabels()
        }
        
        

        // Pan gesture
        self.panRec = UIPanGestureRecognizer(target: self, action: #selector(MainScene.handlePan(recognizer:)))
        self.view!.addGestureRecognizer(panRec)

        // Pinch gesture
        pinchGesture.addTarget(self, action: #selector(handlePinch(sender:)))
        self.view?.addGestureRecognizer(pinchGesture)
    }
    
//    public func playBackgroundSound(player:inout AVAudioPlayer?) {
//        guard let url = Bundle.main.url(forResource: "musicBoque", withExtension: "mp3") else { return }
//
//        do {
//            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
//            try AVAudioSession.sharedInstance().setActive(true)
//
//            //The following line is required for the player to work on iOS 11. Change the file type accordingly*/
//            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
//
//            guard let player = player else { return }
//
//            player.volume = 0.6
//            player.numberOfLoops = -1
//            player.play()
//        }
//        catch let error {
//            print(error.localizedDescription)
//        }
//    }
    
    func playSound(sound : SKAction)
    {
        run(sound)
        run(sound2)
        run(sound3)
        
    }

    // Função do Back Button
    func backButtonAction() {
        // Tira os elementos da tela
        self.reverseAnimateAreaSelection()


        // Tira o zoom
        let zoomAction = SKAction.scale(to: 1, duration: 0.8)
        zoomAction.timingMode = .easeInEaseOut

        // Coloca a câmera no centro da cena
        let moveAction = SKAction.move(to: viewCenter, duration: 0.8)
        moveAction.timingMode = .easeInEaseOut

        // Alpha das logos
        let restoreAlpha = SKAction.fadeAlpha(to: 0.3, duration: 0.2)
        self.wwfLogoNode.run(restoreAlpha)
        self.unicefLogoNode.run(restoreAlpha)

        // Muda as constraints da câmera
        let resetConstraints = SKAction.run {
            self.camera!.constraints = []
        }
        let constAction = SKAction.run {
            self.setCameraConstraint()
        }
        let seqAction = SKAction.sequence([resetConstraints, constAction, zoomAction])

        // Roda as ações
        camera!.run(seqAction)
        camera!.run(moveAction)

        // Permite clicar as áreas novamente
//        self.area1IsTouchable = true
//        self.area2IsTouchable = true
        self.bgAreaIsTouchable = false

        // Funções do onboarding
        self.removeLabelAction()

    
    }
    

//    func removeaction() {
//    self.touch2Label.removeAllActions()
//    self.touch3Label.removeAllActions()
//    self.touchLabel.removeAllActions()
//    self.touchLabelGambiarra.removeAllActions()
//}

    // Função para selecionar a área desejada
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        let touch = touches.first
        let touchLocation = touch!.location(in: self)

        // Posição dos Nodes na Scene
        let area1PlantableX = area1Plantable.position.x
        let area1PlantableY = area1Plantable.position.y + 120
        let firstAreaPosition:CGPoint = CGPoint(x: area1PlantableX, y: area1PlantableY)
        let area2PlantableX = area2Plantable.position.x
        let area2PlantableY = area2Plantable.position.y + 120
        let secondAreaPosition:CGPoint = CGPoint(x: area2PlantableX, y: area2PlantableY)

        if firstAreaNode.contains(touchLocation) && area1IsTouchable {
            self.selectingArea(area: 1, position: firstAreaPosition)

        }
        if secondAreaNode.contains(touchLocation) && area2IsTouchable {
            self.selectingArea(area: 2, position: secondAreaPosition)

        }
        //////////////////////////////////////////
        if bgAreaNode.contains(touchLocation) && bgAreaIsTouchable {
            // RESOLVER OQ FAZER NO FUTURO QND TOCAR NO BG
        }
        //////////////////////////////////////////
    }

    // Função para ajustar o que acontece quando tocar na área selecionada
    func selectingArea(area: Int, position: CGPoint) {
        // Ação de Zoom In
        let zoomAction = SKAction.scale(to: 0.45, duration: 0.5)
        zoomAction.timingMode = .easeInEaseOut

        // Define a área que está sendo selecionada
        areaSelectedGlobal = area

        // UserDefaults do onboarding
        if UserDefaults.standard.bool(forKey: "watched2") == false && UserDefaults.standard.bool(forKey: "watched") == true {
            addLabels2()
            //addLabels3()
        }

        // Desativa a possibilidade de tocar em outra área
//        self.area1IsTouchable = false
//        self.area2IsTouchable = false

//
//        // UserDefaults do onboarding
//        if UserDefaults.standard.bool(forKey: "watched2") == false && UserDefaults.standard.bool(forKey: "watched") == true {
//            addLabels2()
//            addLabels3()
//        }

        self.animateAreaSelection(area: area)

        // Alpha das logos
        let removeAlpha = SKAction.fadeAlpha(to: 0.0, duration: 0.2)
        self.wwfLogoNode.run(removeAlpha)
        self.unicefLogoNode.run(removeAlpha)
//        if UserDefaults.standard.bool(forKey: "watched2") == true {
//            self.touch2Label.removeFromParent()
//        }

        // Ação de movimento
        let moveAction = SKAction.move(to: position, duration: 0.5)
        moveAction.timingMode = .easeInEaseOut

        // Constraints da câmera
        let resetConstraints = SKAction.run {
            self.camera!.constraints = []
        }
        let constAction = SKAction.run {
            self.setCameraConstraint()
        }
        let seqAction = SKAction.sequence([resetConstraints, zoomAction, constAction])

        // Rodar ações
        camera!.run(moveAction)
        camera!.run(seqAction)

        // Ativa a possibilidade de tocar no background
        self.bgAreaIsTouchable = true
    }

    // Onboarding
    func addLabels() {
        touchLabel = SKLabelNode(text: "Cada colina pertence a uma ong.")
        touchLabel!.fontName = "Marker Felt Thin"
        touchLabel!.fontSize = 42.0
        touchLabel!.fontColor = UIColor.black
        touchLabel!.position = CGPoint(x: frame.midX, y: frame.midY - 210.0)
        addChild(touchLabel!)
        UserDefaults.standard.set(true, forKey: "watched")
        let animateLabels = SKAction.sequence([SKAction.fadeAlpha(to: 0.4, duration: 2.0), SKAction.fadeAlpha(to: 1.0, duration: 1.0), SKAction.wait(forDuration: 0.5)])
        touchLabel!.run(SKAction.repeatForever(animateLabels))

        touchLabelGambiarra = SKLabelNode(text: "Qual delas você quer ajudar hoje?")
        touchLabelGambiarra!.fontName = "Marker Felt Thin"
        touchLabelGambiarra!.fontSize = 42.0
        touchLabelGambiarra!.fontColor = UIColor.black
        touchLabelGambiarra!.position = CGPoint(x: frame.midX, y: frame.midY - 260.0)
        addChild(touchLabelGambiarra!)
        UserDefaults.standard.set(true, forKey: "watched")
        touchLabelGambiarra!.run(SKAction.repeatForever(animateLabels))

    }
    func addLabels2() {
        touch2Label = SKLabelNode(text: "escolha uma árvore para plantar na colina")
        touch2Label!.fontName = "Marker Felt Thin"
        touch2Label!.fontSize = 33.0
        touch2Label!.fontColor = UIColor.black
        touch2Label!.zPosition = 5
        touch2Label!.position = CGPoint(x: firstAreaNode.position.x - 190.0, y: firstAreaNode.position.y + 180.0)
        self.camera?.addChild(touch2Label!)

        UserDefaults.standard.set(true, forKey: "watched2")

        let animateLabels2 = SKAction.sequence([SKAction.fadeIn(withDuration: 1.0), SKAction.wait(forDuration: 0.5), SKAction.fadeOut(withDuration: 0.5)])
        touch2Label!.run(SKAction.repeatForever(animateLabels2))

    }
    func addLabels3() {
        touch3Label = SKLabelNode(text: "escolha uma árvore para plantar na colina")
        touch3Label!.fontName = "Marker Felt Thin"
        touch3Label!.fontSize = 42.0
        touch3Label!.fontColor = UIColor.black
        touch3Label!.zPosition = 5
        touch3Label!.position = CGPoint(x: secondAreaNode.position.x + 40.0, y: secondAreaNode.position.y - 20.0)
//        self.camera?.addChild(touch3Label!)

        UserDefaults.standard.set(true, forKey: "watched2")

        let animateLabels3 = SKAction.sequence([SKAction.fadeIn(withDuration: 1.0), SKAction.wait(forDuration: 0.5), SKAction.fadeOut(withDuration: 0.5)])
        touch3Label!.run(SKAction.repeatForever(animateLabels3))
    }
    func addLabels4() {
        touch6Label = SKLabelNode(text: "o dinheiro desse anúncio foi convertido para WWF")
        touch6Label!.fontName = "Marker Felt Thin"
        touch6Label!.fontSize = 33.0
        touch6Label!.fontColor = UIColor.black
        touch6Label!.zPosition = 5
        touch6Label!.position = CGPoint(x: firstAreaNode.position.x - 190.0, y: firstAreaNode.position.y + 1000.0)
        self.camera?.addChild(touch6Label!)
        
        UserDefaults.standard.set(true, forKey: "watched2")
        
        let animateLabels4 = SKAction.sequence([SKAction.fadeIn(withDuration: 1.0), SKAction.wait(forDuration: 0.5), SKAction.fadeOut(withDuration: 0.5)])
        touch6Label!.run(SKAction.repeatForever(animateLabels4))
        
        touch7Label = SKLabelNode(text: "plante mais árvores para continuar ajudando")
        touch7Label!.fontName = "Marker Felt Thin"
        touch7Label!.fontSize = 33.0
        touch7Label!.fontColor = UIColor.black
        touch7Label!.zPosition = 5
        touch7Label!.position = CGPoint(x: firstAreaNode.position.x - 190.0, y: firstAreaNode.position.y + 960.0)
        self.camera?.addChild(touch7Label!)
        touch7Label!.run(SKAction.repeatForever(animateLabels4))
    }
    

    // Função para animar os elementos entrando na tela
    func animateAreaSelection(area: Int) {
        // Ajusta a View Controller para ser acessada
        let viewController = UIApplication.shared.keyWindow!.rootViewController as! ViewController

        // Tira o counter local
        viewController.treesPlantedView.alpha = 0
        viewController.treesPlantedLabel.alpha = 0
        viewController.treesPlantedIcon.alpha = 0

        UIView.animate(withDuration: 0.5) {
            // Faz as infos das ONGs aparecerem
            viewController.ONGInfoView.alpha = 0.8
            viewController.ONGIconImageView.alpha = 1
            viewController.ONGDescriptionLabel.alpha = 1
            viewController.ONGAboutButtonLayout.alpha = 1

//            self.touch2Label?.alpha = 1
//            self.touch3Label?.alpha = 1
//            self.touch4Label?.alpha = 1
//            self.touch5Label?.alpha = 1

            // Back Button surge
            self.backButtonLayout.alpha = 1

            if area == 1 {
                viewController.ONGIconImageView.image = UIImage(named: "ong1")
                viewController.ONGDescriptionLabel.text = "Essa é a WWF"
                self.touch2Label?.run(SKAction.fadeIn(withDuration: 0.9))
                self.touch3Label?.run(SKAction.fadeIn(withDuration: 0.9))
                let animateLabels2 = SKAction.sequence([SKAction.fadeIn(withDuration: 1.0), SKAction.wait(forDuration: 0.5), SKAction.fadeOut(withDuration: 0.5)])
                self.touch2Label?.run(SKAction.repeatForever(animateLabels2))
                self.touchLabel?.removeAllActions()
                self.touchLabelGambiarra?.removeAllActions()
                self.touchLabel?.alpha = 0
                self.touchLabelGambiarra?.alpha = 0
                self.playSound(sound: self.sound3)

            } else if area == 2 {
                viewController.ONGIconImageView.image = UIImage(named: "ong2")
                viewController.ONGDescriptionLabel.text = "Essa é a Unicef"
                self.touch2Label?.run(SKAction.fadeIn(withDuration: 0.9))
                self.touch3Label?.run(SKAction.fadeIn(withDuration: 0.9))
                let animateLabels2 = SKAction.sequence([SKAction.fadeIn(withDuration: 1.0), SKAction.wait(forDuration: 0.5), SKAction.fadeOut(withDuration: 0.5)])
                self.touch2Label?.run(SKAction.repeatForever(animateLabels2))
                self.touchLabel?.removeAllActions()
                self.touchLabelGambiarra?.removeAllActions()
                self.touchLabel?.alpha = 0
                self.touchLabelGambiarra?.alpha = 0
                self.playSound(sound: self.sound3)

            }
        }
        UIView.animate(withDuration: 0.3, delay: 0.5, animations: {
            // Faz a treeSelectionView aparecer
            viewController.treeSelectionView.alpha = 0.8
        })
    }

    // Função para animar os elementos saindo da tela
    func reverseAnimateAreaSelection() {
        // Ajusta a View Controller para ser acessada
        let viewController = UIApplication.shared.keyWindow!.rootViewController as! ViewController

        UIView.animate(withDuration: 0.2) {
            self.backButtonLayout.alpha = 0
            viewController.ONGInfoView.alpha = 0
            viewController.ONGIconImageView.alpha = 0
            viewController.ONGDescriptionLabel.alpha = 0
            viewController.ONGAboutButtonLayout.alpha = 0
            viewController.treeSelectionView.alpha = 0
            viewController.treesPlantedView.alpha = 0.8
            viewController.treesPlantedLabel.alpha = 1
            viewController.treesPlantedIcon.alpha = 1
            self.touch2Label?.alpha = 0
            self.touch3Label?.alpha = 0
            self.touch2Label?.removeFromParent()
            self.touch3Label?.removeFromParent()
        }
    }

    // Função para gerar nós
    func createTree(color: String, x: Double, y: Double, area: Int, new: Bool, animate: Bool) {
        //let treeNode = SKShapeNode(rectOf: CGSize(width: 10, height: 20))
        let treeNode = SKSpriteNode(color: .black, size: CGSize(width: 20, height: 20))
        treeNode.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        treeNode.name = "tree"

        // Define a cor da árvore
        if color == "red" {
            //treeNode.fillColor = SKColor.red
            treeNode.texture = SKTexture(imageNamed: "treeRed")
            
        } else if color == "blue" {
            //treeNode.fillColor = SKColor.blue
            treeNode.texture = SKTexture(imageNamed: "treeBlue")
            
        } else if color == "yellow" {
            //treeNode.fillColor = SKColor.yellow
            treeNode.texture = SKTexture(imageNamed: "treeYellow")
            
        } else if color == "green" {
            //treeNode.fillColor = SKColor.green
            treeNode.texture = SKTexture(imageNamed: "treeGreen")


        }

        // Define a posição da árvore
        if area == 1 {
            treeNode.position = CGPoint(x: x, y: y)
            self.area1Plantable.addChild(treeNode)
            if new {
                // Câmera foca na árvore criada
                var cameraPositionInitial = convert(treeNode.position, from: area1Plantable)
                var cameraPositionX = cameraPositionInitial.x
                var cameraPositionY = cameraPositionInitial.y + 37.0
                var cameraPositionFinal = CGPoint(x: cameraPositionX, y: cameraPositionY)
                camera?.position = cameraPositionFinal
                camera?.setScale(0.1)
//                playSound(sound: sound3)

            }
        }

        if area == 2 {
            treeNode.position = CGPoint(x: x, y: y)
            self.area2Plantable.addChild(treeNode)
            if new {
                // Câmera foca na árvore criada
                var cameraPositionInitial = convert(treeNode.position, from: area2Plantable)
                var cameraPositionX = cameraPositionInitial.x
                var cameraPositionY = cameraPositionInitial.y + 37.0
                var cameraPositionFinal = CGPoint(x: cameraPositionX, y: cameraPositionY)
                camera?.position = cameraPositionFinal
                camera?.setScale(0.1)
//                playSound(sound: sound3)

            }
        }

        if animate {
            treeNode.alpha = 0
            treeNode.run(SKAction.fadeIn(withDuration: 0.2))
        } else {
            treeNode.alpha = 1
        }
    }

    // Função para gerar números aleatórios
    func randomNumber(areaSelected: Int) {
        if areaSelected == 1 {
            self.xMax = Float.random(in: -Float(self.area1Plantable.frame.width)/(Float(self.area1Plantable.xScale)*2) ... Float(self.area1Plantable.frame.width)/(Float(self.area1Plantable.xScale)*2))
            self.yMax = Float.random(in: -Float(self.area1Plantable.frame.height)/(Float(self.area1Plantable.yScale)*2) ... Float(self.area1Plantable.frame.height)/(Float(self.area1Plantable.yScale)*2))
            
        } else if areaSelected == 2 {
            self.xMax = Float.random(in: -Float(self.area2Plantable.frame.width)/(Float(self.area2Plantable.xScale)*2) ... Float(self.area2Plantable.frame.width)/(Float(self.area2Plantable.xScale)*2))
            self.yMax = Float.random(in: -Float(self.area2Plantable.frame.height)/(Float(self.area2Plantable.yScale)*2) ... Float(self.area2Plantable.frame.height)/(Float(self.area2Plantable.yScale)*2))
        }
    }

    var whatArea: Int = 0
    func randomNumberForPlanting() {
        self.whatArea = Int.random(in: 0 ... 3)
        print(whatArea)
    }

}
