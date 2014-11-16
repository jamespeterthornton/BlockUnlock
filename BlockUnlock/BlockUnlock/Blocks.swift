//
//  Block.swift
//  BlockUnlock
//
//  Created by James Thornton on 11/15/14.
//  Copyright (c) 2014 James Thornton. All rights reserved.
//

import Foundation
import SpriteKit

class ComplexBlock : SKSpriteNode {
    
    /*
    * Initialize the block with an array of values.
    * The array will be used to construct the block. 
    * It can have NSNumbers (0 = False, 1 = True) or Connectors as elements
    */
    
    init(values: [NSObject]) {
        
        super.init(texture: nil, color: UIColor.redColor(), size: CGSize(width: 100, height: 100));
        
        if (values.count == 3) {
            
            let sprite = SKSpriteNode(imageNamed: "RedBlock");
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.anchorPoint = CGPointMake(0.0, 0.0);
            sprite.position = CGPointMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame));
            
            self.addChild(sprite);
            
        } else {
            
            assert(false, "Must provide 2, 4, or 6 arguments in ComplexBlock constructor array");
            
        }
        
        
      
        
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
}

class Connector: NSObject {
    
    let writeable: Bool;
    
    let value: String;
    
    init(thisWriteable: Bool, thisValue: String) {
        
        writeable = thisWriteable
        value = thisValue
        
    }
    
}