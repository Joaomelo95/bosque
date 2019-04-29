//
//  MainScene.swift
//  bosque
//
//  Created by João Melo on 29/04/19.
//  Copyright © 2019 João Melo. All rights reserved.
//

import SpriteKit

class MainScene: SKScene {
    
    var area1IsTouchable = true
    var area2IsTouchable = true
    
    // Função para selecionar a área desejada
    // Variáves dos Nodes na Scene
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        
        let cam = self.childNode(withName: "camera")
        
        let firstAreaNode = self.childNode(withName: "area1")!
        let secondAreaNode = self.childNode(withName: "area2")!
        
        let firstAreaPosition = firstAreaNode.position
        let secondAreaPosition = secondAreaNode.position
        
        let zoomAction = SKAction.scale(to: 0.5, duration: 0.5)
        zoomAction.timingMode = .easeInEaseOut
        
        if firstAreaNode.contains(touchLocation) && area1IsTouchable {
            area2IsTouchable = false
            let moveAction = SKAction.move(to: firstAreaPosition, duration: 0.5)
            moveAction.timingMode = .easeInEaseOut
            
            cam?.run(moveAction)
            cam?.run(zoomAction)
        }
        
        if secondAreaNode.contains(touchLocation) && area2IsTouchable {
            area1IsTouchable = false
            let moveAction = SKAction.move(to: secondAreaPosition, duration: 0.5)
            moveAction.timingMode = .easeInEaseOut
            
            cam?.run(moveAction)
            cam?.run(zoomAction)
        }
    }
}
