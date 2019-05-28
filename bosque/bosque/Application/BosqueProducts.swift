//
//  RazeFaceProducts.swift
//  bosque
//
//  Created by Augusto Paixão on 29/04/19.
//  Copyright © 2019 João Melo. All rights reserved.
//

import Foundation

public struct BosqueProducts {
    
    public static let Cerejeira = "com.Joao.bosq.redtree"
    
    public static let Laranjeira = "com.Joao.bosq.bluetree"
    
    public static let Pinheiro = "com.Joao.bosq.yellowtree"
    
    public static let Mandacaru = "com.Joao.bosq.greentree"
    
    public static let Cerejeira2 = "com.Joao.bosq.redtree2post"
    
    public static let Laranjeira2 = "com.Joao.bosq.bluetree2"
    
    public static let Pinheiro2 = "com.Joao.bosq.yellowtree2"
    
    public static let Mandacaru2 = "com.Joao.bosq.greentree2"
    
    private static let productIdentifiers: Set<ProductIdentifier> = [BosqueProducts.Cerejeira, BosqueProducts.Laranjeira, BosqueProducts.Pinheiro, BosqueProducts.Mandacaru, BosqueProducts.Cerejeira2, BosqueProducts.Laranjeira2, BosqueProducts.Pinheiro2, BosqueProducts.Mandacaru2]
    
    public static let store = IAPHelper(productIds: BosqueProducts.productIdentifiers)
}

func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
    return productIdentifier.components(separatedBy: ".").last
}
