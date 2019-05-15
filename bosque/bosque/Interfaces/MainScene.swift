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
    var firstAreaNode = SKNode()
    var secondAreaNode = SKNode()
    var wwfLogoNode = SKNode()
    var unicefLogoNode = SKNode()
    var bgAreaNode = SKNode()
    var area1Plantable = SKNode()
    var area2Plantable = SKNode()
    
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
        
        // Roda as ações
        camera!.run(zoomAction)
        camera!.run(moveAction)
        
        // Permite clicar as áreas novamente
        self.area1IsTouchable = true
        self.area2IsTouchable = true
        self.bgAreaIsTouchable = false
    }
    
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
        
        // Desativa a possibilidade de tocar em outra área
        self.area1IsTouchable = false
        self.area2IsTouchable = false
        
        self.animateAreaSelection(area: area)
        
        // Alpha das logos
        let removeAlpha = SKAction.fadeAlpha(to: 0.0, duration: 0.2)
        self.wwfLogoNode.run(removeAlpha)
        self.unicefLogoNode.run(removeAlpha)
        
        // Ação de movimento
        let moveAction = SKAction.move(to: position, duration: 0.5)
        moveAction.timingMode = .easeInEaseOut
        
        // Rodar ações
        camera!.run(moveAction)
        camera!.run(zoomAction)
        
        // Ativa a possibilidade de tocar no background
        self.bgAreaIsTouchable = true
    }
    
    // Função para animar os elementos entrando na tela
    func animateAreaSelection(area: Int) {
        // Ajusta a View Controller para ser acessada
        let viewController = UIApplication.shared.keyWindow!.rootViewController as! ViewController
        
        // Tira o counter local
        viewController.treesPlantedLabel.alpha = 0
        
        UIView.animate(withDuration: 0.5) {
            // Faz as infos das ONGs aparecerem
            viewController.ONGIconImageView.alpha = 1
            viewController.ONGDescriptionLabel.alpha = 1
            viewController.ONGAboutButtonLayout.alpha = 1
            
            // Back Button surge
            self.backButtonLayout.alpha = 1
            
            if area == 1 {
                viewController.ONGIconImageView.image = UIImage(named: "ong1")
                viewController.ONGDescriptionLabel.text = "Essa é a WWF"
            } else if area == 2 {
                viewController.ONGIconImageView.image = UIImage(named: "ong2")
                viewController.ONGDescriptionLabel.text = "Essa é a Unicef"
            }
        }
        UIView.animate(withDuration: 0.3, delay: 0.5, animations: {
            // Faz a treeSelectionView aparecer
            viewController.treeSelectionView.alpha = 1
        })
    }
    
    // Função para animar os elementos saindo da tela
    func reverseAnimateAreaSelection() {
        // Ajusta a View Controller para ser acessada
        let viewController = UIApplication.shared.keyWindow!.rootViewController as! ViewController
        
        UIView.animate(withDuration: 0.2) {
            self.backButtonLayout.alpha = 0
            viewController.ONGIconImageView.alpha = 0
            viewController.ONGDescriptionLabel.alpha = 0
            viewController.ONGAboutButtonLayout.alpha = 0
            viewController.treeSelectionView.alpha = 0
            viewController.treesPlantedLabel.alpha = 1
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
