import UIkit
import Foundation

//Enum for different connectors, creates and array containing connectors which are
//parsed from user or randomly generated ints
enum ConnectorType {
    case and, or, xor, blank
    
    static let opOrder : [ConnectorType] = [blank, xor, and, or] // in order from lowest to highest
    
    //Blank connector will be filled in by user
    //Method returns connector in exoression
    static func randomType(permitBlank:Bool) -> ConnectorType {
        var index : UInt32
        if (permitBlank) {
            index = arc4random_uniform(UInt32(ConnectorType.opOrder.count))
        } else {
            index = arc4random_uniform(UInt32(ConnectorType.opOrder.count - 1)) + 1
        }
        return ConnectorType.opOrder[Int(index)]
    }
}

/*
Connector class, stores connector characteristics
simple class connector = not simple = 0(false), else simple = 1(true)
*/
class Connector : NSObject {
    var type : ConnectorType
    var writable : Bool
    var simple : Bool
    override var description : String {
        return "\(self.type)"
    }
    
    //Initialize
    init(type:ConnectorType, writable:Bool, simple:Bool) {
        self.type = type
        self.writable = writable
        self.simple = simple
    }
    
    //Parses character type to corresponding connector
    init(type:Character) {
        writable = true
        simple = true
        switch type {
        case "|": self.type = .or
        case "+": self.type = .and
        case "x": self.type = .xor
        case " ": self.type = .blank
        default:  self.type = .blank
        }
    }
    
    //Getter methods
    func isSimple() -> Bool {
        return simple
    }
    func isWritable() -> Bool {
        return self.writable
    }
    func isBlank() -> Bool {
        return isType(ConnectorType.blank)
    }
    func isType(type:ConnectorType) -> Bool {
        return self.type == type
    }
    
    //Returns false if object is not writable
    func set_value(val:String) -> Bool {
        if (!writable) {
            return false
        }
        
        switch (val) {
        case "and":
            self.type = ConnectorType.and
        case "or":
            self.type = ConnectorType.or
        case "xor":
            self.type = ConnectorType.xor
        case "blank":
            fallthrough
        default:
            self.type = ConnectorType.blank
        }
        return true
    }
    
    func getString() -> String {
        switch type {
        case .and: return "+"
        case .or:  return "|"
        case .xor: return "x"
        case .blank: return " "
        default: return "?"
        }
    }
}

/*
Class to create randomely generated simple block
Simple block difficulty must be greater than 1 and less than 6
Class contains boolean statements and connectors
*/
class SimpleBlock {
    var booleans = [NSNumber]()
    var connectors = [Connector]()
    
    //Initializes statements according to difficulty level
    init (difficulty:Int) {
        for index in 0..<difficulty {
            // Booleans
            booleans.append(Int(arc4random_uniform(2)))
            // Connectors
            if (index != (difficulty-1)) {
                var write : Bool = (Int(arc4random_uniform(2)) == 1)
                if (write) { //If connector is blank, insert randomely generated connector
                    connectors.append(Connector(type:ConnectorType.blank, writable:true, simple:true))
                } else {
                    var type : ConnectorType = (ConnectorType.randomType(true))
                    connectors.append(Connector(type:type, writable:false, simple:true))
                }
            }
        }
        // Ensure some Connectors are writable
        connectors[Int(arc4random_uniform(UInt32(connectors.count)))].writable = true
    }
    
    //Initialisation with value of connector
    init (t:String) {
        for (index, char) in enumerate(t) {
            println("\(index/2):\(char)")
            if index%2 == 0 { // Boolean
                booleans.append((char == "0") ? 0 : 1)
            } else { // Connector
                connectors.append(Connector(type:char))
            }
        }
    }
    
    //Returns 0 if false, 1 if true, and nil if blank
    func evaluate() -> Bool? {
        switch evaluateInt() {
        case 0: return false
        case 1: return true
        case 2: return nil
        default: return nil
        }
    }
    
    //Recursively evaluates generated block statement
    func evaluateInt() -> Int {
        return evaluateRecursive(0, end:connectors.count-1, maxOpType:ConnectorType.opOrder.count-1)
    }
    
    func evaluateRecursive(start:Int, end:Int, maxOpType:Int) -> Int {
        //If unary statement
        if (start == end) {
            return booleans[start]
        }
        
        //If statement is binary
        if (start == end-1) {
            return operate(connectors[start], booleans[start], booleans[end])
        }
        
        //Int parses to corresponding operator type
        var currentOpType : Int = maxOpType
        var acted : Bool = false
        
        //Evaluates statement according to logical operators
        while currentOpType > 0 { // skip blank op
            for index in start..<end {
                var op = connectors[index]
                if (!op.isBlank() && op.isType(ConnectorType.opOrder[currentOpType])) {
                    let result = operate(op, evaluateRecursive(start, end:index, maxOpType:currentOpType), evaluateRecursive(index+1, end:end, maxOpType:currentOpType))
                    if (result != 2) { // look for all reasonable interpretations
                        return result
                    }
                }
            }
            currentOpType--;
        }
        
        return 2
    }
    
    //Returns statement as array of objects
    func toArray()->Array<NSObject>{
        var arrayobj = Array<NSObject>()
        for i in 0..<(booleans.count - 1){
            arrayobj.append(booleans[i])
            arrayobj.append(connectors[i])
        }
        arrayobj.append(booleans[booleans.count-1])
        return arrayobj
    }
    
    func getString() -> String {
        var s : String = ""
        for i in 0..<(booleans.count - 1){
            s += "\(booleans[i])"
            s += connectors[i].getString()
        }
        s += "\(booleans[booleans.count-1])"
        return s
    }
}

/*Superblock consists of at least two simpleblocks*/
class SuperBlock {
    var connector:Connector
    var block1:SimpleBlock
    var block2:SimpleBlock
    
    //Initialized with difficulty level
    init (difficulty:Int) {
        block1 = SimpleBlock(difficulty:difficulty/2)
        block2 = SimpleBlock(difficulty:(difficulty - difficulty/2))
        connector = Connector(type:(ConnectorType.randomType(true)), writable:(Int(arc4random_uniform(2)) == 1), simple:false)
    }
    
    //Initialized with logical operator, and two simple blocks
    init (c:Connector, b1:SimpleBlock, b2:SimpleBlock) {
        connector = c
        block1 = b1
        block2 = b2
    }
    
    func toArray()->Array<NSObject>{
        var arrayobj = Array<NSObject>()
        arrayobj.append(block1.toArray())
        arrayobj.append(self.connector)
        arrayobj.append(block2.toArray())
        return arrayobj
    }
    
    func getString() -> String {
        return "(" + block1.getString() + ")" + connector.getString() + "(" + block2.getString() + ")"
    }
    
    func evaluate() -> Bool? {
        switch evaluateInt() {
        case 0: return false
        case 1: return true
        case 2: return nil
        default: return nil
        }
    }
    
    func evaluateInt() -> Int {
        return operate(connector, block1.evaluateInt(), block2.evaluateInt())
    }
}


//Parses statement to ints according to connectors and generated boolean values
func operate(c:Connector, a:Int, b:Int) -> Int {
    // see three-valued logic for guide
    switch c.type {
    case .and:
        if (a == 0 || b == 0) {
            return 0
        } else if (a == 2 || b == 2) {
            return 2
        } else {
            return 1
        }
    case .or:
        if (a == 1 || b == 1) {
            return 1
        } else if (a == 2 || b == 2) {
            return 2
        } else {
            return 0
        }
    case .xor:
        if (a == 2 || b == 2) {
            return 2
        } else if (a != b ) {
            return 1
        } else {
            return 0
        }
    default: return 2
    }
}

