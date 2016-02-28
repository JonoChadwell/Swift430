import Foundation

// Values
class ValueV {
    func toString()->String{
        fatalError("This method must be overridden")
    }
}

class NumV : ValueV {
    let val : Double
    init(_ val : Double) {
        self.val = val
    }
    override func toString()->String{
        return String(stringInterpolationSegment: val);
    }
}

class TrueV : ValueV {
    override func toString()->String {
        return "true"
    }
}

class FalseV : ValueV {
    override func toString()->String {
        return "false"
    }
}

class CloV : ValueV {
    let args : Array<String>
    let body : ExprC
    let env : Dictionary<String,ValueV>
    
    init(_ args : Array<String>,_ body : ExprC,_ env : Dictionary<String, ValueV>) {
        self.args = args
        self.body = body
        self.env = env
    }
    
    override func toString() -> String {
        return "CloV"
    }
    
}

// Expression Types
class ExprC {
    func evaluate(env:Dictionary<String,ValueV>) -> ValueV {
        fatalError("This method must be overridden");
    }
}

class LamC: ExprC {
    var args : Array<String>
    var body : ExprC
    init(_ args : Array<String>,_ body : ExprC) {
        self.args = args
        self.body = body
    }
    
    override func evaluate(env:Dictionary<String,ValueV>)-> ValueV{
        return CloV(args, body, env);
    }
    
}

class LiteralC : ExprC {
    let val : ValueV
    init(_ val : ValueV) {
        self.val = val
    }
    override func evaluate(env:Dictionary<String,ValueV>) -> ValueV {
        return val
    }
}

class BinopC : ExprC {
    let left : ExprC
    let right : ExprC
    init(_ left : ExprC, _ right : ExprC) {
        self.left = left
        self.right = right
    }
    
    override func evaluate(env:Dictionary<String,ValueV>) -> ValueV {
        let l = left.evaluate(env)
        let r = right.evaluate(env)
        if (l is NumV && r is NumV) {
            return doOperator((l as! NumV).val, (r as! NumV).val)
        } else {
            fatalError("Illegal Types")
        }
    }
    
    func doOperator(l : Double, _ r : Double) -> ValueV {
        fatalError("This method must be overridden");
    }
}

class PlusC : BinopC {
    override func doOperator(l : Double, _ r : Double) -> ValueV {
        return NumV(l + r);
    }
}

class MinusC : BinopC {
    override func doOperator(l : Double, _ r : Double) -> ValueV {
        return NumV(l - r);
    }
}

class MultC : BinopC {
    override func doOperator(l : Double, _ r : Double) -> ValueV {
        return NumV(l * r);
    }
}

class DivC : BinopC {

    override func doOperator(l : Double, _ r : Double) -> ValueV {
        if (r == 0) {
            fatalError("Divide By Zero")
        }
        return NumV(l / r);
    }
}

class LeqC : BinopC {
    override func doOperator(l : Double, _ r : Double) -> ValueV {
        if (l <= r) {
            return TrueV()
        } else {
            return FalseV()
        }
    }
}

class CondC : ExprC {
    let cond : ExprC
    let left : ExprC
    let right : ExprC
    init (_ cond : ExprC, _ left : ExprC, _ right : ExprC) {
        self.cond = cond
        self.left = left
        self.right = right
    }
    override func evaluate(env:Dictionary<String,ValueV>) -> ValueV {
        let cval = cond.evaluate(env)
        if (cval is TrueV) {
            return left.evaluate(env)
        } else if (cval is FalseV) {
            return right.evaluate(env)
        } else {
            fatalError("Illegal Types")
        }
    }
}

class IdC : ExprC {
    let name : String
    init(_ name : String) {
        self.name = name
    }
    
    override func evaluate(env: Dictionary<String, ValueV>) -> ValueV {
        return env[name]!
    }
}

// AppC helper functions
func map(l : Array<ExprC>, _ d : Dictionary<String, ValueV>)->Array<ValueV> {
    var newArray : Array<ValueV> = []
    
    for exprc in l {
        newArray.append(exprc.evaluate(d))
    }
    
    return newArray
}

func extendEnv(s : Array<String>, _ v : Array<ValueV>, _ env : Dictionary<String, ValueV>)->Dictionary<String, ValueV> {
    var dict:Dictionary<String, ValueV> = env
    
    if (s.count != v.count) {
        fatalError("Wrongarity");
    } else {
        for i in 0...(s.count - 1){
            dict[s[i]] = v[i];
        }
    }
    
    return dict
}

class AppC : ExprC {
    let function : ExprC
    let args : [ExprC]
    init(_ function : ExprC, _ args : [ExprC]) {
        self.function = function
        self.args = args
    }
    
    override func evaluate(env: Dictionary<String, ValueV>) -> ValueV {
        let cloV = function.evaluate(env) as! CloV
        let newEnv = extendEnv(cloV.args, map(args ,env), cloV.env)
        
        return cloV.body.evaluate(newEnv)
    }
}

// Evaluate a value
let empty = [String : ValueV]()
func topEval(expression : AnyObject) -> String {
    return parse(expression).evaluate(empty).toString()
}

func parse(input : AnyObject) -> ExprC {
    if input is Int || input is Double {
        return LiteralC(NumV(input as! Double))
    } else if (input is String) {
        return IdC(input as! String)
    } else if (input is [AnyObject]) {
        let array = input as! [AnyObject]
        if (array[0] is String) {
            let first = array[0] as! String
            switch (first) {
                    case "+":
                        return PlusC(parse(array[1]), parse(array[2]))
                    case "-":
                        return MinusC(parse(array[1]), parse(array[2]))
                    case "*":
                        return MultC(parse(array[1]), parse(array[2]))
                    case "/":
                        return DivC(parse(array[1]), parse(array[2]))
                    case "<=":
                        return LeqC(parse(array[1]), parse(array[2]))
                    case "func":
                        return LamC(array[1] as! [String], parse(array[2]))
                    case "if":
                        return CondC(parse(array[1]), parse(array[2]), parse(array[3]))
                    default:
                        return AppC(parse(array[0]), array.dropFirst().map(parse))
            }
        } else {
            return AppC(parse(array[0]), array.dropFirst().map(parse))
        }
    } else {
        fatalError("blah")
    }
}

func test(expected : String, _ actual : String) {
    if (expected == actual) {
        print("Test Passed: " + expected + " -> " + actual)
    } else {
        print("Test Failed: " + expected + " -> " + actual)
    }
}

// Test Cases
test("3.0", AppC(LamC(["a", "b"], PlusC(IdC("a"), IdC("b"))), [LiteralC(NumV(2)), LiteralC(NumV(1))]).evaluate(empty).toString())
test("true", (extendEnv(["a", "b"], [TrueV(), FalseV()], [:]))["a"]!.toString())
test("10.0", (extendEnv(["a", "b"], [NumV(10), FalseV()], [:]))["a"]!.toString())
test("30.0", (extendEnv(["a", "b"], [TrueV(), NumV(30)], [:]))["b"]!.toString())
test("10.0", topEval(["*", 2, ["+", 3, 2]]))
test("7.0", topEval([["func", ["a", "b"], ["+", "a", "b"]], 2, 5]))
test("true", topEval([["func", ["f"], ["f", 4]], ["func", ["a"], ["<=", "a", 6]]]))


