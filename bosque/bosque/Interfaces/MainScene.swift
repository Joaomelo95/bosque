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
    
    // Variável para guardar o centro da view
    var viewCenter: CGPoint = CGPoint(x: 0.0, y: 0.0)
    
    // Variável do Back Button
    var backButtonLayout: UIButton!
    
    // Variáves dos Nodes na Scene
    var firstAreaNode = SKNode()
    var secondAreaNode = SKNode()
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        self.firstAreaNode = self.childNode(withName: "area1")!
        self.secondAreaNode = self.childNode(withName: "area2")!
    }
    
    // Função do Back Button
    func backButtonAction() {
        // Tira o botão da tela
        self.backButtonLayout.alpha = 0
        
        let viewController = UIApplication.shared.keyWindow!.rootViewController as! ViewController
        viewController.treeSelectionView.alpha = 0
        
        // Configura a câmera
        let cam = self.childNode(withName: "camera")
        
        // Tira o zoom
        let zoomAction = SKAction.scale(to: 1, duration: 0.5)
        zoomAction.timingMode = .easeInEaseOut
        
        // Coloca a câmera no centro da cena
        let moveAction = SKAction.move(to: viewCenter, duration: 0.5)
        moveAction.timingMode = .easeInEaseOut
        
        // Roda as ações
        cam?.run(zoomAction)
        cam?.run(moveAction)

        // Permite clicar as áreas novamente
        area1IsTouchable = true
        area2IsTouchable = true
    }
    
    // Função para selecionar a área desejada
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        
        // Configuração da câmera
        let cam = self.childNode(withName: "camera")
        
        // Posição dos Nodes na Scene
        let firstAreaPosition = firstAreaNode.position
        let secondAreaPosition = secondAreaNode.position
        
        // Ação de Zoom In
        let zoomAction = SKAction.scale(to: 0.5, duration: 0.5)
        zoomAction.timingMode = .easeInEaseOut
        
        if firstAreaNode.contains(touchLocation) && area1IsTouchable {
            // Define a área que está sendo selecionada
            areaSelected = 1
            
            // Desativa a possibilidade de tocar em outra área
            area1IsTouchable = false
            area2IsTouchable = false
            
            // Ajusta a View Controller para ser acessível pela Scene
            let viewController = UIApplication.shared.keyWindow!.rootViewController as! ViewController
            
            // Faz a treeSelectionView aparecer
            viewController.treeSelectionView.alpha = 1
            
            // Ação de movimento
            let moveAction = SKAction.move(to: firstAreaPosition, duration: 0.5)
            moveAction.timingMode = .easeInEaseOut
            
            // Rodar ações
            cam?.run(moveAction)
            cam?.run(zoomAction)
            
            // Back Button surge
            self.backButtonLayout.alpha = 1
        }
        
        if secondAreaNode.contains(touchLocation) && area2IsTouchable {
            // Define a área que está sendo selecionada
            areaSelected = 2
            
            // Desativa a possibilidade de tocar em outra área
            area1IsTouchable = false
            area2IsTouchable = false
            
            // Ajusta a View Controller para ser acessível pela Scene
            let viewController = UIApplication.shared.keyWindow!.rootViewController as! ViewController
            
            // Faz a treeSelectionView aparecer
            viewController.treeSelectionView.alpha = 1
            
            // Ação de movimento
            let moveAction = SKAction.move(to: secondAreaPosition, duration: 0.5)
            moveAction.timingMode = .easeInEaseOut
            
            // Rodar ações
            cam?.run(moveAction)
            cam?.run(zoomAction)
            
            // Back Button surge
            self.backButtonLayout.alpha = 1
        }
    }
    
    // Função para gerar nós
    func createTree(color: String, x: Double, y: Double, area: Int) {
        let treeNode = SKShapeNode(rectOf: CGSize(width: 10, height: 20))
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
        
        if areaSelected == 1 {
            self.randomNumber(node: self.firstAreaNode)
            treeNode.position = CGPoint(x: CGFloat(self.xMax), y: CGFloat(self.yMax))
            self.firstAreaNode.addChild(treeNode)
        }
        
        if areaSelected == 2 {
            self.randomNumber(node: self.secondAreaNode)
            treeNode.position = CGPoint(x: CGFloat(self.xMax), y: CGFloat(self.yMax))
            self.secondAreaNode.addChild(treeNode)
        }
    }
    
    // Função para gerar números aleatórios
    func randomNumber(node: SKNode) {
        self.xMax = Float.random(in: -Float(node.frame.width)/6 ... Float(node.frame.width)/6)
        self.yMax = Float.random(in: -Float(node.frame.height)/6 ... Float(node.frame.height)/6)
    }
}
