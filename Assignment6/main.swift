import Foundation

print("Hello, World!")

print("This is a test")

// Values
class ValueV {
    func toString()->String{
        preconditionFailure("This method must be overridden")
    }
}
class NumV : ValueV {
    //let val : Int
    let val : Int
    init(_ val : Int) {
        self.val = val
    }
    override func toString()->String{
        return String(val);
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

// Expressions
class ExprC {
    func evaluate() -> ValueV {
        preconditionFailure("This method must be overridden");
    }
}

class LiteralC : ExprC {
    let val : ValueV
    init(_ val : ValueV) {
        self.val = val
    }
    override func evaluate() -> ValueV {
        return val
    }
}

class PlusC : ExprC {
    let left : ExprC
    let right : ExprC
    init(_ left : ExprC, _ right : ExprC) {
        self.left = left
        self.right = right
    }
    override func evaluate() -> ValueV {
        let lval = left.evaluate() as! NumV
        let rval = right.evaluate() as! NumV
        return NumV(lval.val + rval.val)
    }
}

class IdC : ExprC {
    let name : String
    init(_ name : String) {
        self.name = name
    }
}

class AppC : ExprC {
    let function : ExprC
    let args : [ExprC]
    init(_ function : ExprC, _ args : [ExprC]) {
        self.function = function
        self.args = args
    }
}

let thing = PlusC(LiteralC(NumV(4)), LiteralC(NumV(6)))


func parse(input : AnyObject) -> ExprC {
    if (input is Int){
        return LiteralC(NumV(input as! Double))
    } else if (input is Double) {
        return LiteralC(NumV(input as! Double))
    } else if (input is String) {
        return IdC(input as! String)
    } else if (input is [AnyObject]) {
        let array = input as! [AnyObject]
        if (array[0] is String) {
            let first = array[0] as! String
            switch (first) {
                    case "+":
                        return PlusC (parse(input[1]), parse(input[2]))
                    case "-":
                        return MinusC (parse(input[1]), parse(input[2]))
                    case "*":
                        return MultC (parse(input[1]), parse(input[2]))
                    case "/":
                        return DivC (parse(input[1]), parse(input[2]))
                    default:
                        return IdC (input[0] as! String)
            }
        }
        else {
            preconditionFailure("wrong format")
        }
    }
}

parse(["plus", ["minus", 1, 2], [2]])



print((thing.evaluate() as! NumV).val)