import Foundation

println("Hello, World!")

println("This is a test")

// Values
class ValueV {
    func toString()->String{
        preconditionFailure("This method must be overridden")
    }
}
class NumV : ValueV {
    //let val : Int
    var val : Int
    init(_val : Int) {
        val = _val
    }
    override func toString()->String{
        return String(val);
    }
}
class TrueV : ValueV {}
class FalseV : ValueV {}

// Expressions
class ExprC {

}
class LiteralC : ExprC {
    let val : ValueV
    init(_val : ValueV) {
        val = _val
    }
}
class PlusC : ExprC {
    let left : ExprC
    let right : ExprC
    init(_left : ExprC, _right : ExprC) {
        left = _left
        right = _right
    }
}

func Interp(exp : ExprC)->ValueV {
    if ((exp as? LiteralC) != nil) {
        return (exp as! LiteralC).val
    } else if ((exp as? PlusC) != nil) {
        let expP = exp as! PlusC
        return NumV(_val:(Interp(expP.left) as! NumV).val + (Interp(expP.right) as! NumV).val)
    } else {
        return FalseV()
    }
}

let thing = PlusC(_left:LiteralC(_val:NumV(_val:4)), _right:LiteralC(_val:NumV(_val:5)))
let numV = NumV(_val:5);

println(numV.toString())


println((Interp(thing) as! NumV).val)