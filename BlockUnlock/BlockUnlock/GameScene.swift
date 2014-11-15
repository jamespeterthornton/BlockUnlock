//
//  GameScene.swift
//  BlockUnlock
//
//  Created by James Thornton on 11/15/14.
//  Copyright (c) 2014 James Thornton. All rights reserved.
//

import SpriteKit

var blocks: [SKSpriteNode] = [];

class GameScene: SKScene {
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Hellooo, World!";
        myLabel.fontSize = 65;
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        self.addChild(myLabel)
        var timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("generateBlock"), userInfo: nil, repeats: true)
        
    }

    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {

        NSLog("Touch!");
        
    }
    
    
    func generateBlock () {
        
        let sprite = SKSpriteNode(imageNamed: "Spaceship");
        
        sprite.xScale = 0.5
        sprite.yScale = 0.5
        sprite.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame));
        
        let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
        
        sprite.runAction(SKAction.repeatActionForever(action))
        
        self.addChild(sprite)
        
        blocks.append(sprite);
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        for sprite in blocks {
            sprite.position.y -= 3;
        }
        
    }
}
