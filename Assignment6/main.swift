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

class NumC : ExprC {
    let num : Int
    init(_ num : Int) {
        self.num = num;
    }
}

class LiteralC : ExprC {
    let val : ValueV
    init(_ val : ValueV) {
        self.val = val
    }
}

class PlusC : ExprC {
    let left : ExprC
    let right : ExprC
    init(_ left : ExprC,_ right : ExprC) {
        self.left = left
        self.right = right
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
    let args = [ExprC]
    init(_ function : ExprC,_ args : [ExprC]) {
        self.function = function
        self.args = args
    }
}


class TrueC : ExprC {}
class FalseC : ExprC {}

// Interp
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