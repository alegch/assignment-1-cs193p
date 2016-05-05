//
//  ViewController.swift
//  Calc
//
//  Created by Chebulaev Oleg on 27.04.16.
//  Copyright © 2016 Perpetuum Mobile Lab. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var historyLabel: UILabel!
    
    let brain = BrainCalculator()
    var isTyping = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    var displayValue: Double {
        set {
            displayLabel.text = String(newValue)
        }
        get {
            return Double(displayLabel.text!)!
        }
    }
    
    var historyValue: String {
        set {
            historyLabel.text = newValue
        }
        get {
            return historyLabel.text!
        }
    }
    
    @IBAction func onButtonTapped(sender: UIButton) {
        let digit = sender.currentTitle!
        if isTyping {
            displayLabel.text = displayLabel.text! + digit
        } else {
            displayLabel.text = digit
        }
        
        isTyping = true
    }
    
    @IBAction func onOperationTapped(sender: UIButton) {
        if (isTyping) {
            brain.setOperand(displayValue)
        }
        isTyping = false
        if let operation = sender.currentTitle {
            brain.performOperation(operation)
            displayValue = brain.result()
            if brain.isPartialResult {
                historyValue = brain.log + "..."
            } else {
                historyValue = brain.log + "="
            }
        }
    }
    
    @IBAction func onResetTapped(sender: UIButton) {
        brain.reset()
        historyValue = brain.log
        displayValue = brain.result()
        isTyping = false
    }
}

