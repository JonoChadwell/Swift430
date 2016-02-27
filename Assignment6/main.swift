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

// Expressions
class ExprC {
    func evaluate() -> ValueV {
        fatalError("This method must be overridden")
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

class BinopC : ExprC {
    let left : ExprC
    let right : ExprC
    init(_ left : ExprC, _ right : ExprC) {
        self.left = left
        self.right = right
    }
    override func evaluate() -> ValueV {
        let l = left.evaluate()
        let r = left.evaluate()
        if (l is NumV && r is NumV) {
            return doOperator((l as! NumV).val, r: (r as! NumV).val)
        } else {
            fatalError("Illegal Types")
        }
    }
    func doOperator(l : Double, r : Double) -> ValueV {
        fatalError("This method must be overridden");
    }
}

class PlusC : BinopC {
    override func doOperator(l : Double, r : Double) -> ValueV {
        return NumV(l + r);
    }
}

class MinusC : BinopC {
    override func doOperator(l : Double, r : Double) -> ValueV {
        return NumV(l - r);
    }
}

class MultC : BinopC {
    override func doOperator(l : Double, r : Double) -> ValueV {
        return NumV(l * r);
    }
}

class DivC : BinopC {

    override func doOperator(l : Double, r : Double) -> ValueV {
        if (r == 0) {
            fatalError("Divide By Zero")
        }
        return NumV(l / r);
    }
}

class LeqC : BinopC {
    override func doOperator(l : Double, r : Double) -> ValueV {
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
    override func evaluate() -> ValueV {
        let cval = cond.evaluate()
        if (cval is TrueV) {
            return left.evaluate()
        } else if (cval is FalseV) {
            return right.evaluate()
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
}

class AppC : ExprC {
    let function : ExprC
    let args : [ExprC]
    init(_ function : ExprC, _ args : [ExprC]) {
        self.function = function
        self.args = args
    }
}

func NumC(num : Double) -> ExprC {
    return LiteralC(NumV(num))
}

func FalseC() -> ExprC {
    return LiteralC(FalseV())
}

func TrueC() -> ExprC {
    return LiteralC(TrueV())
}

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
            fatalError("wrong format")
        }
    } else
    {
        fatalError("blah")
    }
}

let thing = CondC(LeqC(NumC(4), NumC(6)), TrueC(), FalseC())
parse(["plus", ["minus", 1, 2], [2]])
print(parse(["+", 2, ["-", 3, 2]]).evaluate().toString())

print(thing.evaluate().toString())