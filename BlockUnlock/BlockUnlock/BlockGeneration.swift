import UIKit
import Foundation

//Enum for different connectors, creates and array containing connectors which are
//parsed from user or randomly generated ints
enum ConnectorType {
    case xor, and, or, blank
    
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
    
    static func strictlyAfter(a:ConnectorType, b:ConnectorType) -> Bool {
        return precedence(a) > precedence(b)
    }
    static func validBefore(a:ConnectorType, b:ConnectorType) -> Bool {
        return precedence(a) <= precedence(b)
    }
    static func precedence(c:ConnectorType) -> Int {
        switch c {
        case or:    return 3
        case and:   return 2
        case xor:   return 1
        case blank: return 3
        default:    return 0
        }
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
    init(str:Character) {
        switch str {
        case "|": type = .or
        case "+": type = .and
        case "x": type = .xor
        case " ": type = .blank
        default:  type = .blank
        }
        simple = true
        writable = (type == .blank)
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
    func setType(val:String) -> Bool {
        if (!writable) {
            return false
        }
        
        switch (val) {
        case "AND":   type = ConnectorType.and
        case "OR":    type = ConnectorType.or
        case "XOR":   type = ConnectorType.xor
        case "Blank": fallthrough
        default:      type = ConnectorType.blank
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
    
    func getName() -> String {
        switch type {
        case .and: return "AND"
        case .or:  return "OR"
        case .xor: return "XOR"
        case .blank: return "Blank"
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
            if (index > 1 && booleans[index-1]==booleans[index-2]) { // no more than 2 same in a row
                booleans.append(((booleans[index-1] as Int)+1) % 2)
            } else {
                booleans.append(Int(arc4random_uniform(2)))
            }
            // Connectors
            if (index < (difficulty-1)) {
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
        let index = Int(arc4random_uniform(UInt32(connectors.count)))
        connectors[index].writable = true
        connectors[index].setType("Blank")
    }
    
    //Initialisation with value of connector
    init (str:String) {
        for (index, char) in enumerate(str) {
            if index%2 == 0 { // Boolean
                booleans.append((char == "0") ? 0 : 1)
            } else { // Connector
                connectors.append(Connector(str:char))
            }
        }
    }
    
    //Returns 0 if false, 1 if true, and nil if unknown
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
        return evaluateRecursive(0, end:connectors.count, maxOpType:ConnectorType.opOrder.count-1)
    }
    
    func evaluateRecursive(start:Int, end:Int, maxOpType:Int) -> Int {
        //If unary statement
        if (start == end) {
            return booleans[start] as Int
        }
        
        //Int parses to corresponding operator type
        var currentOpType : Int = maxOpType
        var acted : Bool = false
        
        //Evaluates statement according to logical operators
        while currentOpType > 0 { // skip blank op
            for index in start..<end {
                var op = connectors[index]
                if (!op.isBlank() && op.isType(ConnectorType.opOrder[currentOpType])) {
                    let resultA = evaluateRecursive(start, end:index, maxOpType:currentOpType)
                    var result = operate(op, resultA, 2) // short circuit
                    if (result != 2) { // result is knowable
                        return result
                    }
                    result = operate(op, resultA, evaluateRecursive(index+1, end:end, maxOpType:currentOpType))
                    if (result != 2) { // result is knowable
                        return result
                    }
                    // else continue, look for all reasonable interpretations
                }
            }
            currentOpType--;
        }
        return 2
    }
    
    func evaluateTo(goal:Bool) -> Bool {
        return evaluateToRecursive(goal, start:0, end:connectors.count, maxOpType:ConnectorType.opOrder.count-1)
    }
    
    func evaluateToRecursive(goal:Bool, start:Int, end:Int, maxOpType:Int) -> Bool {
        //If unary statement
        if (start == end) {
            return booleans[start] == (goal ? 1 : 0)
        }
        
        //Int parses to corresponding operator type
        var currentOpType : Int = maxOpType
        var acted : Bool = false
        
        //Evaluates statement according to logical operators
        while currentOpType >= 0 {
            for index in start..<end {
                var op = connectors[index]
                if (!op.isWritable() && ConnectorType.strictlyAfter(op.type, b:ConnectorType.opOrder[currentOpType])) {
                    return false
                }
                if (op.isWritable() || op.isType(ConnectorType.opOrder[currentOpType])) {
                    let aFalsable = evaluateToRecursive(false, start:start, end:index, maxOpType:currentOpType)
                    let aTruable =  evaluateToRecursive(true,  start:start, end:index, maxOpType:currentOpType)
                    let bFalsable = evaluateToRecursive(false, start:index+1, end:end, maxOpType:currentOpType)
                    let bTruable =  evaluateToRecursive(true,  start:index+1, end:end, maxOpType:currentOpType)
                    switch ConnectorType.opOrder[currentOpType] {
                    case .and:
                        if (goal == true && (aTruable && bTruable)) {
                            return true
                        } else if (goal == false && (aFalsable || bFalsable)) {
                            return true
                        }
                    case .or:
                        if (goal == true && (aTruable || bTruable)) {
                            return true
                        } else if (goal == false && (aFalsable && bFalsable)) {
                            return true
                        }
                    case .xor:
                        if (goal == true && ((aTruable && bFalsable) || (aFalsable && bTruable))) {
                            return true
                        } else if (goal == false && ((aTruable && bTruable) || (aFalsable && bFalsable))) {
                            return true
                        }
                    default:
                        break;
                    }
                }
            }
            currentOpType--;
        }
        return false
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
        for i in 0..<(connectors.count){
            s += "\(booleans[i])"
            s += connectors[i].getString()
        }
        s += "\(booleans[booleans.count-1])"
        return s
    }
    func debugString() -> String {
        return "simple = \(getString()) = \(evaluate()) currently. Truable = \(evaluateTo(true)), Falsable = \(evaluateTo(false))"
    }
}

extension Array {
    mutating func shuffle() {
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            swap(&self[i], &self[j])
        }
    }
}

/*Superblock consists of at least two simpleblocks*/
class SuperBlock {
    var connectors = [Connector]()
    var blocks = [SimpleBlock]()
    
    //Initialized with difficulty level
    init (difficulty:Int) {
        // Cases: 3-3, 2-4, 4-2, 2-2-2
        var numbers = [UInt32]()
        if (difficulty == 6) {
            switch (arc4random_uniform(8)) {
            case 0:     numbers = [2, 2, 2]
            case 1,2:   numbers = [2, 4]
            case 3,4:   numbers = [4, 2]
            case 5,6,7: fallthrough
            default:    numbers = [3, 3]
            }
        } else {
            var remaining = UInt32(difficulty)
            if remaining < 4 {
                remaining = 4
            }
            while remaining > 3 {
                var next = (arc4random_uniform(remaining-3) % 3) + 2 // 2 to remaining-2 or 5
                numbers.append(next)
                remaining -= next
            }
            numbers.append(remaining)
            numbers.shuffle()
        }
        for number in numbers {
            blocks.append(SimpleBlock(difficulty:Int(number)))
            if (blocks.count < numbers.count) {
                connectors.append(Connector(type:(ConnectorType.randomType(true)), writable:(Int(arc4random_uniform(2)) == 1), simple:false))
            }
        }
        for connector in connectors {
            if connector.isWritable() {
                connector.setType("Blank")
            }
        }
        for block in blocks { // disable (FF) blocks
            if (block.booleans.count == 2 && block.booleans[0] == 0 && block.booleans[1] == 0) {
                if arc4random_uniform(100) > 0 { // ...most of the time
                    block.booleans[Int(arc4random_uniform(2))] = 1
                }
            }
        }
    }
    
    init (str:String) {
        var array : [String] = str.componentsSeparatedByCharactersInSet(NSCharacterSet (charactersInString: "()"))
        array.removeLast()
        array.removeAtIndex(0)
        var block = true
        for s in array {
            if block {
                blocks.append(SimpleBlock(str:s))
            } else {
                connectors.append(Connector(str:(Array(s)[0])))
            }
            block = !block
        }
    }
    
    //Returns 0 if false, 1 if true, and nil if unknown
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
        return evaluateRecursive(0, end:connectors.count, maxOpType:ConnectorType.opOrder.count-1)
    }
    
    func evaluateRecursive(start:Int, end:Int, maxOpType:Int) -> Int {
        //If unary statement
        if (start == end) {
            return blocks[start].evaluateInt()
        }
        
        //Int parses to corresponding operator type
        var currentOpType : Int = maxOpType
        var acted : Bool = false
        
        //Evaluates statement according to logical operators
        while currentOpType > 0 { // skip blank op
            for index in start..<end {
                var op = connectors[index]
                if (!op.isBlank() && op.isType(ConnectorType.opOrder[currentOpType])) {
                    let resultA = evaluateRecursive(start, end:index, maxOpType:currentOpType)
                    var result = operate(op, resultA, 2) // short circuit
                    if (result != 2) { // result is knowable
                        return result
                    }
                    result = operate(op, resultA, evaluateRecursive(index+1, end:end, maxOpType:currentOpType))
                    if (result != 2) { // result is knowable
                        return result
                    }
                    // else continue, look for all reasonable interpretations
                }
            }
            currentOpType--;
        }
        return 2
    }
    
    func evaluateTo(goal:Bool) -> Bool {
        return evaluateToRecursive(goal, start:0, end:connectors.count, maxOpType:ConnectorType.opOrder.count-1)
    }
    
    func evaluateToRecursive(goal:Bool, start:Int, end:Int, maxOpType:Int) -> Bool {
        //If unary statement
        if (start == end) {
            return blocks[start].evaluateTo(goal)
        }
        
        //Int parses to corresponding operator type
        var currentOpType : Int = maxOpType
        var acted : Bool = false
        
        //Evaluates statement according to logical operators
        while currentOpType >= 0 {
            for index in start..<end {
                var op = connectors[index]
                if (!op.isWritable() && ConnectorType.strictlyAfter(op.type, b:ConnectorType.opOrder[currentOpType])) {
                    return false
                }
                if (op.isWritable() || op.isType(ConnectorType.opOrder[currentOpType])) {
                    let aFalsable = evaluateToRecursive(false, start:start, end:index, maxOpType:currentOpType)
                    let aTruable =  evaluateToRecursive(true,  start:start, end:index, maxOpType:currentOpType)
                    let bFalsable = evaluateToRecursive(false, start:index+1, end:end, maxOpType:currentOpType)
                    let bTruable =  evaluateToRecursive(true,  start:index+1, end:end, maxOpType:currentOpType)
                    switch ConnectorType.opOrder[currentOpType] {
                    case .and:
                        if (goal == true && (aTruable && bTruable)) {
                            return true
                        } else if (goal == false && (aFalsable || bFalsable)) {
                            return true
                        }
                    case .or:
                        if (goal == true && (aTruable || bTruable)) {
                            return true
                        } else if (goal == false && (aFalsable && bFalsable)) {
                            return true
                        }
                    case .xor:
                        if (goal == true && ((aTruable && bFalsable) || (aFalsable && bTruable))) {
                            return true
                        } else if (goal == false && ((aTruable && bTruable) || (aFalsable && bFalsable))) {
                            return true
                        }
                    default:
                        break;
                    }
                }
            }
            currentOpType--;
        }
        return false
    }
    
    //Returns statement as array of objects
    func toArray() -> Array<NSObject> {
        var arrayobj = Array<NSObject>()
        for i in 0..<(blocks.count - 1) {
            arrayobj += blocks[i].toArray()
            arrayobj.append(connectors[i])
        }
        arrayobj += blocks[blocks.count-1].toArray()
        return arrayobj
    }
    func getString() -> String {
        var s : String = ""
        for i in 0..<(connectors.count){
            s += "(\(blocks[i].getString()))"
            s += connectors[i].getString()
        }
        s += "(\(blocks[blocks.count-1].getString()))"
        return s
    }
    func debugString() -> String {
        return "super = \(getString()) = \(evaluate()) currently. Truable = \(evaluateTo(true)), Falsable = \(evaluateTo(false))"
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
        /*  case .iff:
        if (a == 2 || b == 2) {
        return 2
        } else if (a == b) {
        return 1
        } else {
        return 0
        }*/
    default: return 2
    }
}

/*
* Wrapper class for blocks
* Pass in length as "difficulty"
*/
class GenericBlock {
    var goal : Bool
    var isSuper : Bool
    var superB : SuperBlock?
    var simpleB : SimpleBlock?
    
    init (difficulty:Int) {
        var status : Bool?
        do {
            if difficulty > 4 {
                superB = SuperBlock(difficulty: difficulty)
                status = superB?.evaluate()
                isSuper = true
            } else {
                simpleB = SimpleBlock(difficulty: difficulty)
                status = simpleB?.evaluate()
                isSuper = false
            }
            if status == nil {
                goal = Int(arc4random_uniform(2)) == 1
            } else {
                goal = !status!
            }
        } while (!isSolvable())
    }
    
    func isSolvable() -> Bool {
        return isSuper ? superB!.evaluateTo(goal) : simpleB!.evaluateTo(goal)
    }
    func isSolved() -> Bool {
        var status = evaluate()
        return status != nil && status == goal
    }
    func evaluate() -> Bool? {
        return isSuper ? superB!.evaluate() : simpleB!.evaluate()
    }
    func toArray() -> [NSObject] {
        return isSuper ? superB!.toArray() : simpleB!.toArray()
    }
    func getString() -> String {
        return isSuper ? superB!.getString() : simpleB!.getString()
    }
}

/*
var s = GenericBlock(difficulty:25)
println(s.getString())
println(s.evaluate())
println(s.isSolvable())
println(s.evaluateTo(!a.goal))
*/

/*
var a = SimpleBlock(str:"0|1|1 0") // goal false
var b = SuperBlock(str:"(1+0|1)+(0+1)") // goal false
println(b.evaluate())
println(b.blocks[0].evaluate())
println(b.blocks[1].evaluate())
var c = SuperBlock(str:"(1x1|0)x(1|1)") // goal true
println(c.evaluate())
println(c.blocks[0].evaluate())
println(c.blocks[1].evaluate())
*/