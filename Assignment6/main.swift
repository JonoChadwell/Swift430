import Foundation

print("Hello, World!")

print("This is a test")

// Values
class ValueV {}
class NumV : ValueV {
    let val : Int
    init(_ val : Int) {
        self.val = val
    }
}
class TrueV : ValueV {}
class FalseV : ValueV {}


// Expressions
class ExprC {
    func evaluate() -> ValueV {
        preconditionFailure("We are pretending this is abstract");
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
        return NumV((left.evaluate() as! NumV).val + (right.evaluate() as! NumV).val)
    }
}

let thing = PlusC(LiteralC(NumV(4)), LiteralC(NumV(5)))

print((thing.evaluate() as! NumV).val)