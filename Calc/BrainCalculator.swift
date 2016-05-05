//
//  BrainCalculator.swift
//  Calc
//
//  Created by Chebulaev Oleg on 27.04.16.
//  Copyright © 2016 Perpetuum Mobile Lab. All rights reserved.
//

import Foundation

class BrainCalculator {
    let operations:Dictionary<String, Operation> = ["+": Operation.Binary({$0 + $1}),
                                                    "−": Operation.Binary({$0 - $1}),
                                                    "×": Operation.Binary({$0 * $1}),
                                                    "÷": Operation.Binary({$0 / $1}),
                                                   "Pi": Operation.Constant(M_PI),
                                                  "sin": Operation.Unary({sin($0)}),
                                                  "cos": Operation.Unary({cos($0)}),
                                                   "tg": Operation.Unary({tan($0)}),
                                                    "∓": Operation.Unary({-$0}),
                                                    "=": Operation.Equality]
    var accamulator = 0.0
    var binaryTemp:BinaryTemp? = nil
    internal private(set) var log = ""
    internal private(set) var isPartialResult = false
    var lastOperand = 0.0
    var endComputing = false
    var isWaitBinaryOperand = true
    var isNeedReset = false
    
    func reset() -> Void {
        accamulator = 0.0
        log = ""
        isPartialResult = false
        lastOperand = 0.0
        endComputing = false
        isWaitBinaryOperand = true
        isNeedReset = false
    }
    
    func setOperand(operand: Double) {
        setOperand(operand, functionName: "", logValue: true)
    }
    
    func setOperand(operand: Double, functionName:String, logValue:Bool) {
        accamulator = operand
        if isNeedReset {
            log = logValue ? String(operand) : functionName
            isNeedReset = false
        } else {
            log += logValue ? String(operand) : functionName
        }
        
        if isPartialResult {
            isWaitBinaryOperand = true
        } else {
            isWaitBinaryOperand = false
        }
        lastOperand = operand
    }
    
    
    func result() -> Double {
        return accamulator
    }
    
    func performOperation(operation: String) -> Void {
        let op = operations[operation]
        if let function = op {
            switch function {
            case .Binary(let binaryFunction):
                performIfExistBinary()
                binaryTemp = BinaryTemp(firstArgument: accamulator, operation: binaryFunction)
                isPartialResult = true
                log += operation
                if endComputing {
                    isNeedReset = false
                }
            case .Equality:
                if (!isWaitBinaryOperand) {
                    log += String(lastOperand)
                }
                performIfExistBinary()
                endComputing = true
            case .Unary(let unaryFunction):
                accamulator = unaryFunction(accamulator)
                if endComputing {
                    isNeedReset = true
                }
                
                if binaryTemp != nil {
                    let range = log.rangeOfString(String(lastOperand), options: NSStringCompareOptions.BackwardsSearch, range: nil, locale: nil);
                    if let operandRange = range {
                        let newOperand = operation + "(" + String(lastOperand) + ")"
                        log = log.stringByReplacingCharactersInRange(operandRange, withString: newOperand)
                    }
                } else {
                    log = operation + "(" + log + ")"
                }
            case .Constant(let constant):
                setOperand(constant, functionName: operation, logValue: false)
            }
        }
    }
    
    func performIfExistBinary() {
        if binaryTemp != nil {
            accamulator = binaryTemp!.operation(binaryTemp!.firstArgument, accamulator)
            isPartialResult = false
            binaryTemp = nil
        }
    }
    
    struct BinaryTemp {
        var firstArgument:Double
        var operation: (Double, Double) -> Double
    }
    
    enum Operation {
        case Unary((Double) -> Double)
        case Constant(Double)
        case Binary((Double, Double) -> Double)
        case Equality
    }
}