//
//  ViewController.swift
//  Homework1
//
//  Created by Carlos Rosario on 7/11/16.
//  Copyright © 2016 Carlos Rosario. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    var currentlyChosenTipPercentage: Float = 10
    var customTip = false
    
    @IBOutlet weak var tipTotalLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var sliderLabel: UILabel!
    @IBOutlet weak var customTipPercentageSlider: UISlider!
    @IBOutlet weak var totalBillTextField: UITextField!
    @IBOutlet weak var tipSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.totalBillTextField.delegate = self
        totalBillTextField.addTarget(self, action: #selector(ViewController.performCalculation(_:)), forControlEvents: UIControlEvents.EditingChanged)

    }
    
    // Computed property to connect the slider and its label
    private var sliderValue: Float {
        get {
            return customTipPercentageSlider.value
        }
        set {
            customTipPercentageSlider.value = newValue
            sliderLabel.text = String(newValue) + "%"
        }
    }
    
    func textField(textField: UITextField,shouldChangeCharactersInRange range: NSRange,replacementString string: String) -> Bool
    {
        let newCharacters = NSCharacterSet(charactersInString: string)
        let boolIsNumber = NSCharacterSet.decimalDigitCharacterSet().isSupersetOfSet(newCharacters)
        if boolIsNumber == true {
            return true
        } else {
            if string == "." {
                let countdots = textField.text!.componentsSeparatedByString(".").count - 1
                if countdots == 0 {
                    return true
                } else {
                    if countdots > 0 && string == "." {
                        return false
                    } else {
                        return true
                    }
                }
            } else {
                return false
            }
        }
    }
    
    func updateValues(){
        if let billValue = Float(totalBillTextField.text!){
            let tip = currentlyChosenTipPercentage / 100
            let tipValue = tip * billValue
            let totalValue = billValue + tipValue
            
            // update labels
            tipTotalLabel.text = String(tipValue)
            totalLabel.text = String(totalValue)
        }
        else {
            tipTotalLabel.text = "0.00"
            totalLabel.text = "0.00"
        }
    }
    
    func performCalculation(textField: UITextField) {
        updateValues()
    }
    
    @IBAction func clearAllButton(sender: UIButton) {
        // Reset total bill, tip, total, custom slider to 25%, and segmented control to 10%
        totalBillTextField.text = ""
        tipTotalLabel.text = "0.00"
        totalLabel.text = "0.00"
        sliderValue = 25
        tipSegmentedControl.selectedSegmentIndex = 0
    }
    
    
    
    @IBAction func customTipPercentageChanged(sender: UISlider) {
        currentlyChosenTipPercentage = sliderValue
        // Need to update slider label
        sliderLabel.text = sliderValue.description + "%"
        
        // Update labels if custom is chosen
        if(customTip == true){
            updateValues()
        }
    }

    @IBAction func tipPercentageSelected(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0:
            // 10%
            currentlyChosenTipPercentage = 10
            customTip = false
            updateValues()
        case 1:
            // 15%
            currentlyChosenTipPercentage = 15
            customTip = false
            updateValues()
        case 2:
            // 18%
            currentlyChosenTipPercentage = 18
            customTip = false
            updateValues()
        case 3:
            // Custom needs to be set to the value of the slider
            currentlyChosenTipPercentage = sliderValue
            customTip = true
        default: break
        }
    }
}

