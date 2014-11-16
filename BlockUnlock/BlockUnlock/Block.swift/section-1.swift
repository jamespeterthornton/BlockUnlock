// Playground - noun: a place where people can play

import UIKit
import Foundation

class SimpleBlock{
    var booleans = [NSInteger]()
    var connectors = [Connectors]()
    
    init (difficulty:Int) {
        
        //Generate bools
        for index in 0..<difficulty {
            var num:Int = Int(arc4random_uniform(2)) //Check
            if (num == 1){
                self.booleans.append(1)
            }else {
                self.booleans.append(0)
                }
            
            //Generate connectors
            if (index != (difficulty - 2)){
                num = Int(arc4random_uniform(2)) //Check
                if (num == 1){
                    var to_add:Connectors = Connectors(write:false,type:0)
                    self.connectors.append(to_add)
                }else {
                    var to_add:Connectors = Connectors(write:true,type:0)
                    self.connectors.append(to_add)
                }
                }
            }

            
            //Check
            var truevalues:Int = 0
            var falsevalues:Int = 0
            for p in connectors{
                if (p.writable){
                    truevalues++
                }
                else{
                    falsevalues++
                }
            }
            if((truevalues==0) || (falsevalues == 0)){
                for (var i = 0;i < connectors.count;i+2){
                    if(connectors[i].writable){
                        connectors[i].writable = false
                    }
                    else{
                        connectors[i].writable = true
                    }
                }
            }
        }
    
    func toArray()->Array<NSObject>{
        var i = 0
        var arrayobj = Array<NSObject>()
        
        for p in 0..<(booleans.count - 1){
            arrayobj.append(booleans[p])
            arrayobj.append(connectors[i])
            i++
            }
        
        arrayobj.append(booleans[booleans.count-1])
        return arrayobj
    }
}

class SuperBlock{
    var connector:Connectors
    var block1:SimpleBlock
    var block2:SimpleBlock
    
    init (Block1:SimpleBlock,Block2:SimpleBlock, difficulty:Int){
        var value = Int(arc4random_uniform(2))
        self.block1 = Block1
        self.block2 = Block2
        
        if (value == 1){
            self.connector = Connectors(write:true,type:1)
        }
        else{
            self.connector = Connectors(write:false,type:1)
        }
    }
    
    //ToArrayMethod
    func toArray()->Array<NSObject>{
            var arrayobj = Array<NSObject>()
            arrayobj.append(block1.toArray())
            arrayobj.append(self.connector)
            arrayobj.append(block2.toArray())
        return arrayobj
    }

}

    class Connectors: NSObject {
    var writable:Bool
    var value:NSString = ""//Temp
    var isSimple:Bool
    var description:String{
        return "\(self.value)"
        }
    
    //0 is Simple Block, 1 is Complex Block
    init(write:Bool,type:Int){
        self.writable = write
        
        if(type == 0){
            self.isSimple = true
        }
        else{
            self.isSimple = false
        }
    }
    
    //Returns false if object is not writable
    func set_value(val:String) -> Bool{
        if (writable){
            self.value = val
            return true
        }
        else{
            return false
        }
    }
    
    func get_status()-> Bool{
        return self.writable
    }
}


var a = SimpleBlock(difficulty:5)
var b = SimpleBlock(difficulty:7)
var c = SuperBlock(Block1:a,Block2:b,difficulty:8)

println(a.toArray())
println(b.toArray())
println(c.toArray())

