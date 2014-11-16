//
//  GameScene.swift
//  BlockUnlock
//
//  Created by James Thornton on 11/15/14.
//  Copyright (c) 2014 James Thornton. All rights reserved.
//

import SpriteKit

var blocks: [SKSpriteNode] = [];

var counter: Int = 0;

class GameScene: SKScene {
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Hellooo, World!";
        myLabel.fontSize = 65;
        myLabel.position = CGPoint(x:CGRectGetMinX(self.frame), y:CGRectGetMidY(self.frame));
        self.addChild(myLabel)
        println("WIDTH IS: \(self.frame.width.description)")
        
    }

    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {

        NSLog("Touch!");
        
    }
    
    
    func generateBlock () {
        
        NSLog("Game scene width %@", self.frame.width);
        
        let difficulty : Int = Int(arc4random()) % 5 + 1;
        
        print("And the difficulty is...");
        
        println("\(difficulty)");
        
        let simpleArray : GenericBlock = GenericBlock(difficulty: difficulty);

        let complexBlock : ComplexBlock = ComplexBlock(newValues: simpleArray.toArray(), target: simpleArray.goal);
        
        complexBlock.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame));
        
        
        self.addChild(complexBlock)
        blocks.append(complexBlock)

    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        if (counter == 100){ counter = 0;}
        if (counter == 0){ generateBlock();}
        counter++;
        
        for sprite in blocks {
            sprite.position.y -= 3;
        }
        
    }
}
