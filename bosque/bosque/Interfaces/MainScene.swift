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
    
    // Variáveis do Onboarding
    var touchLabel : SKLabelNode!

    
    // Inicializador
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        self.firstAreaNode = self.childNode(withName: "area1")!
        self.secondAreaNode = self.childNode(withName: "area2")!
        self.wwfLogoNode = self.childNode(withName: "wwfLogo")!
        self.unicefLogoNode = self.childNode(withName: "unicefLogo")!
        self.bgAreaNode = self.childNode(withName: "bg")!
//        pinch alternativa
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(self.handlePinchFrom(_:)))
            self.view?.addGestureRecognizer(pinchGesture)
        if UserDefaults.standard.bool(forKey: "watched") == false {
            addLabels()
        }
    }
    
    //adicionar onboarding dicas
    func addLabels() {

        touchLabel = SKLabelNode(text: "toque uma área\n para ajudar uma ONG")
        touchLabel.fontName = "AvenirNext-Bold"
        touchLabel.fontSize = 35.0
        touchLabel.fontColor = UIColor.black
        touchLabel.position = CGPoint(x: frame.midX, y: frame.midY + 400)
        addChild(touchLabel)

        UserDefaults.standard.set(true, forKey: "watched")
        
    }
    

//    UserDefaults.standard.integer(forKey: "watch"
    
//    função de pinch
//    @objc private func pinchHandler(gesture: UIPinchGestureRecognizer) {
//        if let view = gesture.view {
//
//            switch gesture.state {
//            case .changed:
//                let pinchCenter = CGPoint(x: gesture.location(in: view).x - view.bounds.midX,
//                                          y: gesture.location(in: view).y - view.bounds.midY)
//                let transform = view.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
//                    .scaledBy(x: gesture.scale, y: gesture.scale)
//                    .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
//                view.transform = transform
//                gesture.scale = 1.0
//            case .ended:
//                UIView.animate(withDuration: 0.2, animations: {
//                    view.transform = CGAffineTransform.identity
//
//                })
//            default:
//                return
//            }
//        }
//    }

    @objc func handlePinchFrom(_ sender: UIPinchGestureRecognizer) {
        print("is piching!")
        if sender.scale >= 0.2 && sender.scale <= 1 && area1IsTouchable && area2IsTouchable {
            if let view = sender.view {
                
                if sender.state == .began {
                    
                } else if sender.state == .changed {
                    let pinchCenter = CGPoint(x: sender.location(in: view).x - view.bounds.midX,
                                              y: sender.location(in: view).y - view.bounds.midY)
                    let transform = view.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                        
                        .scaledBy(x: sender.scale, y: sender.scale)
                        .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
                    view.transform = transform
                    //                                sender.scale = 1.0
                    
                    
                    camera?.setScale(sender.scale)
                    //                let pinch = SKAction.scale(by: sender.scale, duration: 0.0)
                    //                camera?.run(pinch)
                    
                    
                } else if sender.state == .ended {
                    
                }
            }
        }
    }
    
    // Função do Back Button
    func backButtonAction() {
        // Tira os elementos da tela
        self.reverseAnimateAreaSelection()
        
        // Configura a câmera
        //let cam = self.childNode(withName: "camera")
        
        // Tira o zoom
        let zoomAction = SKAction.scale(to: 1, duration: 0.5)
        zoomAction.timingMode = .easeInEaseOut
        
        // Coloca a câmera no centro da cena
        let moveAction = SKAction.move(to: viewCenter, duration: 0.5)
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
        let firstAreaPositionX = firstAreaNode.position.x
        let firstAreaPositionY = firstAreaNode.position.y + 120
        let firstAreaPosition:CGPoint = CGPoint(x: firstAreaPositionX, y: firstAreaPositionY)
        let secondAreaPositionX = secondAreaNode.position.x
        let secondAreaPositionY = secondAreaNode.position.y + 120
        let secondAreaPosition:CGPoint = CGPoint(x: secondAreaPositionX, y: secondAreaPositionY)
        
        if firstAreaNode.contains(touchLocation) && area1IsTouchable {
            self.selectingArea(area: 1, position: firstAreaPosition)
        }
        if secondAreaNode.contains(touchLocation) && area2IsTouchable {
            self.selectingArea(area: 2, position: secondAreaPosition)
        }
        //////////////////////////////////////////
        if bgAreaNode.contains(touchLocation) && bgAreaIsTouchable {
            // RESOLVER OQ FAZER NO FUTURO
        }
        //////////////////////////////////////////
    }
    
    // Função para ajustar o que acontece quando tocar na área selecionada
    func selectingArea(area: Int, position: CGPoint) {
        // Configuração da câmera
        //let cam = self.childNode(withName: "camera")
        
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
                self.touchLabel.removeFromParent()
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
        }
    }
    
    // Função para gerar nós
    func createTree(color: String, x: Double, y: Double, area: Int, new: Bool) {
        //let treeNode = SKShapeNode(rectOf: CGSize(width: 10, height: 20))
        let treeNode = SKSpriteNode(color: .black, size: CGSize(width: 50, height: 50))
        treeNode.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        treeNode.zPosition = 3
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
            self.firstAreaNode.addChild(treeNode)
            if new {
                // CRIAR MOVIMENTAÇÃO DE CÂMERA PARA FOCAR NA ÁRVORE CRIADA
            }
        }
        
        if area == 2 {
            treeNode.position = CGPoint(x: x, y: y)
            self.secondAreaNode.addChild(treeNode)
            if new {
                // CRIAR MOVIMENTAÇÃO DE CÂMERA PARA FOCAR NA ÁRVORE CRIADA
            }
        }
    }
    
    // Função para gerar números aleatórios
    func randomNumber(areaSelected: Int) {
        if areaSelected == 1 {
            self.xMax = Float.random(in: -Float(self.firstAreaNode.frame.width)/(Float(self.firstAreaNode.xScale)*2) ... Float(self.firstAreaNode.frame.width)/(Float(self.firstAreaNode.xScale)*2))
            self.yMax = Float.random(in: -Float(self.firstAreaNode.frame.height)/(Float(self.firstAreaNode.yScale)*2) ... Float(self.firstAreaNode.frame.height)/(Float(self.firstAreaNode.yScale)*2))
        } else if areaSelected == 2 {
            self.xMax = Float.random(in: -Float(self.secondAreaNode.frame.width)/(Float(self.secondAreaNode.xScale)*2) ... Float(self.secondAreaNode.frame.width)/(Float(self.secondAreaNode.xScale)*2))
            self.yMax = Float.random(in: -Float(self.secondAreaNode.frame.height)/(Float(self.secondAreaNode.yScale)*2) ... Float(self.secondAreaNode.frame.height)/(Float(self.secondAreaNode.yScale)*2))
        }
    }
}
