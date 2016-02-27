import Foundation

print("Hello, World!")

print("This is a test")

// Values
class ValueV {}
class NumV : ValueV {
    let val : Int
    init(_val : Int) {
        val = _val
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