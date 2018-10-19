//
//  CustomerDetailViewController.swift
//  assignment-2
//
//  Created by Tripp,Jacob on 10/4/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

// ["Name": "Jake Tripp",
//  "Email__c": "shmogens@gmail.com",
//  "Address__c": "123 Apple Street",
//  "City__c": "San Antonio",
//  "State__c": "TX",
//  "Zip__c": "78209"]

import UIKit
import Eureka

/// Protocol that allows controller to be delegate for CustomerDetailVC.
// class type must implement this protocol
protocol CustomerDetailProtocol: class {
    func reloadTableData()
    func showCustomerActionFailureAlert(title: String, message: String)
}

/// Track current form state.
enum CurrentAction {
    case updating
    case creating
}

class CustomerDetailViewController: FormViewController {
    
    var customers : Customers!
    var customer : Customer!
    // made weak so that memory can properly be deallocated (get rid of the cycles)
    weak var delegate : CustomerDetailProtocol?
    
    /// What the user is currently doing (creating or updating)
    var userIsCurrently : CurrentAction = .creating
    
    /// Form items tag constants.
    /// Basically IDs for each row in the form.
    let formItems : [String:String] = [
        "name": "Name",
        "email": "Email__c",
        "street": "Address__c",
        "city": "City__c",
        "state": "State__c",
        "zip": "Zip__c",
        "submitButton": "submitButton"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Validation.setEurekaRowDefaults()
        
        /// Section title for the form, based on whether the user is updating or creating.
        let sectionTitle = userIsCurrently == .updating ? "Update info" : "Create a new customer"
        
        /// Submit button text for the form, based on whether the user is updating or creating.
        let buttonText = userIsCurrently == .updating ? "Update" : "Create"
        
        form +++ Section(sectionTitle)
            // MARK: - NAME
            <<< TextRow(formItems["name"]) {
                $0.title = "Name"
                $0.placeholder = "John Smith"
                $0.value = customer.name
                $0.add(rule: RuleRequired(msg: "Name field required!"))
                $0.add(rule: RuleMaxLength(maxLength: 80, msg: "Name cannot be longer than 80 characters!"))
            }
            
            // MARK: - EMAIL
            <<< EmailRow(formItems["email"]) {
                $0.title = "Email"
                $0.placeholder = "john.smith@gmail.com"
                $0.value = customer.email
                $0.add(rule: RuleEmail())
            }
            
            // MARK: - ADDRESS
            <<< TextRow(formItems["street"]) {
                $0.title = "Address"
                $0.placeholder = "123 Apple Street"
                $0.value = customer.street
                $0.add(rule: RuleMaxLength(maxLength: 255, msg: "Address cannot be longer than 255 characters!"))
            }
            
            // MARK: - CITY
            <<< TextRow(formItems["city"]) {
                $0.title = "City"
                $0.placeholder = "San Antonio"
                $0.value = customer.city
                $0.add(rule: RuleMaxLength(maxLength: 255, msg: "City cannot be longer than 255 characters!"))
            }
            
            // MARK: - STATE
            <<< PickerInlineRow<String>(formItems["state"]) { (row : PickerInlineRow<String>) -> Void in
                row.title = "State"
                row.noValueDisplayText = "Pick a state"
                row.options = ["", "AK", "AL", "AR", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "GA", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY"]
                row.value = customer.state
                // set row value to nil if user sets state to empty string
                row.onCellSelection() { cell, row in
                    if row.value == "" {
                        row.value = nil
                    }
                }
            }
            
            // MARK: - ZIP
            <<< ZipCodeRow(formItems["zip"]) {
                $0.title = "Zip Code"
                $0.placeholder = "12345"
                $0.value = customer.zip
                $0.add(rule: RuleExactLength(exactLength: 5))
                $0.add(rule: RuleClosure<String> { input in
                    // if it's nil or empty, do nothing
                    if  (input ?? "").isEmpty {
                        return nil
                        // if it can be casted to an int, do nothing
                    } else if input != nil, let _ = Int(input!) {
                        return nil
                    } else {
                        return ValidationError(msg: "Zip codes must only contain numbers!")
                    }
                })
            }
            
            // MARK: - SUBMIT
            <<< ButtonRow(formItems["submitButton"]) {
                $0.title = buttonText
                let tags = Array(formItems.values)
                $0.disabled = Condition.function(tags, { form in
                    return !form.validate().isEmpty
                })
                $0.onCellSelection({ (cell, row) in
                    // no validation errors
                    if let validationErrors : [ValidationError] = row.section?.form?.validate(), validationErrors.isEmpty {
                        
                        let formValues = self.form.values()
                        var newCustomer = Customer(formValues)
                        
                        if self.userIsCurrently == .creating {
                            
                            self.handleCreate(newCustomer)
                            
                        } else if self.userIsCurrently == .updating {
                            
                            self.handleUpdate(newCustomer)
                            
                        }
                        
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                })
        }
        
    }
    
    // MARK: - CREATE
    /// Saves the customer in a fake-hashed-id, reloads the table data, then sends the create request to SF.
    func handleCreate(_ newCustomer: Customer) {
        // use uuid because no id for creating new-customer
        let fakeHashId = NSUUID().uuidString
        self.customers.dictionary[fakeHashId] = newCustomer
        delegate?.reloadTableData()
        self.customers.create(newCustomer, fakeHashId, completion: self.createCompletion)
    }
    
    /// If request was successful, saves the customer in the new customer's id.
    /// If request failed, shows an error alert.
    /// Removes the old fake-hash-id either way.
    func createCompletion(fakeId: String, realId: String?, newCustomer: Customer?, error: Error?) {
        
        // remove fakeHashId
        self.customers.dictionary[fakeId] = nil
        
        if error != nil {
            
            // show alert
            let title = "Unable to create customer"
            let message = "Sorry, we couldn't create a new customer."
            delegate?.showCustomerActionFailureAlert(title: title, message: message)
            
            // log error
            print(error ?? title)
            
        } else {
            if let id = realId {
                
                // set customer to real customer id
                self.customers.dictionary[id] = newCustomer
                delegate?.reloadTableData()
            }
        }
    }
    
    // MARK: - UPDATE
    /// If needed, updates the old-customer to be the new-customer, reloads the table data, then sends the create request to SF.
    func handleUpdate(_ customerPassed: Customer) {
        
        var newCustomer = customerPassed
        
        // there is something to update - non-equivalent
        if !(self.customer == newCustomer) {
            
            newCustomer.id = self.customer.id
            
            // set old-customer equal to new-customer in dictionary
            self.customers.dictionary[newCustomer.id!] = newCustomer
            
            delegate?.reloadTableData()
            
            self.customers.update(from: self.customer, to: newCustomer, completion: self.updateCompletion)
            
        } else {
            print("no update needed")
        }
    }
    
    /// If request failed, shows an error alert, reverts new-customer back to old-customer, and reloads the table data.
    func updateCompletion(customerId: String, oldCustomer: Customer, error: Error?) {
        if error != nil {
            // show alert
            let title = "Unable to update customer"
            let message = "Sorry, we couldn't update the customer's data."
            delegate?.showCustomerActionFailureAlert(title: title, message: message)
            
            // log error
            print(error ?? title)
            
            // if request failed, revert new-customer back to old-customer
            self.customers.dictionary[customerId] = oldCustomer
            
            delegate?.reloadTableData()
        }
    }
    
}
