//
//  GameScene.swift
//  BlockUnlock
//
//  Created by James Thornton on 11/15/14.
//  Copyright (c) 2014 James Thornton. All rights reserved.
//

import SpriteKit

var blocks: [ComplexBlock] = []
var targets: [Bool] = []
var targetSprites : [SKSpriteNode] = []
var counter: Int = 0
let controlsHeight : CGFloat = 150
let targetHeight : CGFloat = 75
var gameOver : Bool = false
var score : Int = 0;


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
        
        evaluateTrue();
        
    }
    
    func evaluateTrue() {
        
        if (!gameOver) {
    
            if targetSprites.count > 0 {
            
                score += 1
            
                println("\(targetSprites.count)");
            
                let block : ComplexBlock = blocks.removeAtIndex(0);
                let target : Bool = targets.removeAtIndex(0);
                let targetSprite : SKSpriteNode = targetSprites.removeAtIndex(0);
            
                let moveAction = SKAction.moveTo(CGPointMake(targetSprite.position.x, targetSprite.position.y), duration: 0.3);
            
                block.runAction(moveAction, completion: { () -> Void in
                
                    block.hasExploded()
                    self.explode( block.position.x, y: block.position.y)
                    block.hidden = true
                
            })
            
            addTarget(target)
        }
        }
        
    }
    
    func addTarget(color : Bool) {
        
        let targetColor : UIColor = color ? UIColor.blueColor() : UIColor.redColor()
        
        let newTargetNode = SKSpriteNode(texture: nil, color: targetColor.colorWithAlphaComponent(0.7), size: CGSizeMake(self.frame.width, targetHeight))
        
        newTargetNode.position.x = CGRectGetMidX(self.frame);
        newTargetNode.position.y = CGRectGetMinY(self.frame) + controlsHeight
        
        self.addChild(newTargetNode);
        
        targetSprites.append(newTargetNode);
    }
    
    func generateBlock () {
        
        let difficulty : Double = Double(arc4random()) % 4.0 + 2.0;
        let simpleArray : GenericBlock = GenericBlock(difficulty: Int(difficulty));
        let newTarget : Bool = simpleArray.goal;
        let complexBlock : ComplexBlock = ComplexBlock(newValues: simpleArray.toArray(), target: simpleArray.goal);
        
        complexBlock.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) + 300);
        self.addChild(complexBlock)
        blocks.append(complexBlock)
        targets.append(newTarget);
        
        if (targets.count == 1) {
            
            addTarget(newTarget)
        }
        
    }
    
    func explode(x: CGFloat, y: CGFloat) {
        var sparkEmmitterPath:NSString = NSBundle.mainBundle().pathForResource("redExplosion", ofType: "sks")!
        var sparkEmmiter = NSKeyedUnarchiver.unarchiveObjectWithFile(sparkEmmitterPath) as SKEmitterNode
        sparkEmmiter.position.x = x
        sparkEmmiter.position.y = y
        sparkEmmiter.name = "sparkEmmitter"
        sparkEmmiter.targetNode = self
        self.addChild(sparkEmmiter)
        
        sparkEmmiter.runAction(SKAction.fadeOutWithDuration(0.20))
        NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: "destroyParticle:", userInfo: sparkEmmiter, repeats: false)
        
        println("exploded")
    }
    
    func destroyParticle(timer: NSTimer) -> () {
        println(1)
        var userInfo = timer.userInfo as SKEmitterNode
        userInfo.alpha = 0.0
        println("\(userInfo.parent)")
        userInfo.removeFromParent()
        
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if (!gameOver) {
            if (counter == 150){ counter = 0;}
            if (counter == 0){ generateBlock();}
            counter++;
        
            for sprite in blocks {
                sprite.position.y -= 3;
            }
        
            if targetSprites.count > 0 && blocks.count > 0 {
                if targetSprites[0].position.y == blocks[0].position.y {
                
                    gameOver = true;
                    
                    var button: Button = Button(defaultButtonImage: "restartbut1", activeButtonImage: "restartbut1_active", buttonAction: restart)

                    let gameOverSprite : GameOverSprite = GameOverSprite (spriteSize: CGSize(width: 400.0, height: 400.0), restartBut: button)
                
                    gameOverSprite.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
                
                    gameOverSprite.zPosition = 1500
                
                    self.addChild(gameOverSprite)
                }
            
            }
        }
        
    }
    
    func restart () {
        self.removeAllChildren()
        
    }
}
