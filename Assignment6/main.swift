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

  //[cloV (arg : (listof symbol)) (body : ExprC) (env : Env)]


// Expressions
class ExprC {
    func evaluate(env:Dictionary<String,ValueV>) -> ValueV {
        preconditionFailure("This method must be overridden");
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
        let lval = left.evaluate(env) as! NumV
        let rval = right.evaluate(env) as! NumV
        return NumV(lval.val + rval.val)
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



func extendEnv (s : Array<String>, v : Array<ValueV>, env : Dictionary<String, ValueV>)->Dictionary<String, ValueV> {
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

func map (l : Array<ExprC>, d : Dictionary<String, ValueV>)->Array<ValueV> {
    var newArray : Array<ValueV> = []
    
    for exprc in l {
        newArray.append(exprc.evaluate(d))
    }
    
    return newArray
}

var emptyEnv = [String : ValueV]()

let app :ExprC = AppC(LamC(["a", "b"], PlusC(IdC("a"), IdC("b"))), [LiteralC(NumV(2)), LiteralC(NumV(1))])
let val : ValueV = app.evaluate(emptyEnv)

println("expecting value of 3 received -> " + val.toString())

//var arr : Array<ExprC> = [LiteralC(1), LiteralC(2), LiteralC(3)]
var arr : Array<ValueV> = map([LiteralC(NumV(1)), LiteralC(FalseV()), LiteralC(NumV(3))], emptyEnv)


println("expect following values to be 1, false, and 3 ")

for numb in arr {
    println(numb.toString())
}


println("expect to be 'true' value is -> " + (extendEnv(["a", "b"], [TrueV(), FalseV()], [:]))["a"]!.toString())
println("expect to be '10' value is -> " + (extendEnv(["a", "b"], [NumV(10), FalseV()], [:]))["a"]!.toString())
println("expect to be '30' value is -> " + (extendEnv(["a", "b"], [TrueV(), NumV(30)], [:]))["b"]!.toString())

/*
[appC (f a) (local ([define f-value (interp f env)])
    (interp (cloV-body f-value)
    (extend-env (cloV-arg f-value)
    (map (lambda (i) (interp i env)) a)
    (cloV-env f-value))))]

*/


let thing = PlusC(LiteralC(NumV(4)), LiteralC(NumV(6)))
let idcTest = IdC("a")
var numV = NumV(5)

var nonEmptyEnv = ["a" : numV]


println((idcTest.evaluate(nonEmptyEnv) as! NumV).val)
println((thing.evaluate(emptyEnv) as! NumV).val)






