//
//  ViewController.swift
//  TechnicalAssessment
//
//  Created by Nino on 11/22/23.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var nameErrorMessageLabel: UILabel!
    @IBOutlet weak var regionLabel: UILabel!
    @IBOutlet weak var regionTextField: UITextField!
    @IBOutlet weak var regionErrorMessageLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var countryErrorMessageLabel: UILabel!
    
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var autocompleteTableView: UITableView!
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var countries:[Country]!
    var regions: [String]!
    var filteredCountries = [Country]()
    var selectedCountry:Country!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        fetchCountries { countries in
            self.countries = countries
            
            let allRegions = (self.countries ?? []).compactMap { $0.region }
            self.regions = Array(Set(allRegions))
            self.regions.sort()
            
            self.regions.insert("Select region", at: 0)
            
            self.hideLoading()

        }
    }
    
    func setupUI() {
        nameLabel.text = "Name"
        nameTextfield.placeholder = "Name"
        nameErrorMessageLabel.text = ""
        nameErrorMessageLabel.textColor = UIColor.red
        
        nameTextfield.addTarget(self, action: #selector(UIInputViewController.dismissKeyboard), for: .primaryActionTriggered)
        
        regionLabel.text = "Region"
        regionTextField.placeholder = "Select your region"
        regionErrorMessageLabel.text = ""
        regionErrorMessageLabel.textColor = UIColor.red
        
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()

        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(UIInputViewController.dismissKeyboard))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
      

        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        regionTextField.inputView = picker
        regionTextField.inputAccessoryView = toolBar
        
        countryLabel.text = "Country"
        countryTextField.placeholder = "Search"
        countryErrorMessageLabel.text = ""
        countryErrorMessageLabel.textColor = UIColor.red

        countryTextField.addTarget(self, action: #selector(UIInputViewController.dismissKeyboard), for: .primaryActionTriggered)
        
        submitButton.setTitle("Submit", for: .normal)
        clearButton.setTitle("Clear", for: .normal)
        
        autocompleteTableView.register(UITableViewCell.self, forCellReuseIdentifier: "AutoCompleteRowIdentifier")
        
        autocompleteTableView.delegate = self
        autocompleteTableView.dataSource = self
        autocompleteTableView.isUserInteractionEnabled = true
        autocompleteTableView.allowsSelection = true
        autocompleteTableView.isHidden = true

        countryTextField.delegate = self
        
        showLoading()
        
    }
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        var validated = true
        let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ ")
        
        
        if let name = nameTextfield.text, name.rangeOfCharacter(from: characterset.inverted) != nil {
            
            setErrorFor(textField: nameTextfield, label: nameLabel, errorLabel: nameErrorMessageLabel, errorMessage: "Cannot contain alphanumeric or special characters")
            validated = false
        } else if nameTextfield.text?.count == 0 {
            setErrorFor(textField: nameTextfield, label: nameLabel, errorLabel: nameErrorMessageLabel, errorMessage: "You must enter a name")
            validated = false

        } else {
            removeErrorFor(textField: nameTextfield, label: nameLabel, errorLabel: nameErrorMessageLabel)
        }
        
        if regionTextField.text?.count == 0 {
            setErrorFor(textField: regionTextField, label: regionLabel, errorLabel: regionErrorMessageLabel, errorMessage: "You must select a region")

            validated = false
        }
        
        if countryTextField.text?.count == 0 || selectedCountry == nil{
            setErrorFor(textField: countryTextField, label: countryLabel, errorLabel: countryErrorMessageLabel, errorMessage: "You must a valid country")

            validated = false
        }
        
        if (validated) {
            performSegue(withIdentifier: "showDetails", sender: self)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" {
            if let  detailsVC:DetailsViewController = segue.destination as? DetailsViewController  {
                detailsVC.setData(name: nameTextfield.text!, country: selectedCountry)
            }
        }
    }
    
    @IBAction func clearButtonPressed(_ sender: Any) {
        
        nameErrorMessageLabel.text = ""
        nameTextfield.text = ""
        removeErrorFor(textField: nameTextfield, label: nameLabel, errorLabel: nameErrorMessageLabel)
        
        regionErrorMessageLabel.text = ""
        regionTextField.text = ""
        removeErrorFor(textField: regionTextField, label: regionLabel, errorLabel: regionErrorMessageLabel)
        
        countryErrorMessageLabel.text = ""
        countryTextField.text = ""
        removeErrorFor(textField: countryTextField, label: countryLabel, errorLabel: countryErrorMessageLabel)
        selectedCountry = nil

    }
    
    
    func showLoading() {
        activityIndicator.startAnimating()
        loadingView.isHidden = false
    }
    
    func hideLoading() {
        activityIndicator.stopAnimating()
        loadingView.isHidden = true

    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func fetchCountries(completion: @escaping (([Country])->()) ) {
        AF.request("https://restcountries.com/v3.1/all").responseDecodable(of: [Country].self) { response in
            switch response.result {
                
                case .success(let countries):
                
                    completion(countries)
                    break

                case .failure(let productFetcherror):
                
                    let alert = UIAlertController(title: "Failed to load", message: productFetcherror.errorDescription, preferredStyle: .alert)
                    self.present(alert, animated: true)
                
            }

        }
        
    }
    
    func setErrorFor(textField: UITextField, label: UILabel, errorLabel: UILabel, errorMessage: String) {
        label.textColor = UIColor.red
        errorLabel.text = errorMessage
        textField.layer.borderColor = UIColor.red.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = regionTextField.frame.height / 5
    }
    
    func removeErrorFor(textField: UITextField, label: UILabel, errorLabel: UILabel) {
        label.textColor = UIColor.black
        errorLabel.text = ""
        
        textField.layer.borderWidth = 0
        
    }
}
extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let regions = regions {
            return regions.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let regions = regions {
            return regions[row]
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let regions = regions, row > 0 {
            regionTextField.text = regions[row]
            removeErrorFor(textField: regionTextField, label: regionLabel, errorLabel: regionErrorMessageLabel)
            
            countryTextField.text = ""
        }
        
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredCountries.count > 3 {
            return 3
        } else {
            return filteredCountries.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let autoCompleteRowIdentifier = "AutoCompleteRowIdentifier"
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: autoCompleteRowIdentifier, for: indexPath) as UITableViewCell
                
        cell.textLabel!.text = filteredCountries[indexPath.row].name.common
        return cell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        dismissKeyboard()
        
        selectedCountry = filteredCountries[indexPath.row]
        self.countryTextField.text = selectedCountry.name.common
        autocompleteTableView.isHidden = true
        
        removeErrorFor(textField: countryTextField, label: countryLabel, errorLabel: countryErrorMessageLabel)
    }
}

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if regionTextField.text?.count == 0 {
            setErrorFor(textField: regionTextField, label: regionLabel, errorLabel: regionErrorMessageLabel, errorMessage: "You must select a region")

            return false
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if(string == "\n") {
            dismissKeyboard()
            return false
        }
        
        if string.count == 0 {
            autocompleteTableView.isHidden = true
            return true
        }
        
        autocompleteTableView.isHidden = false
        let substring = (textField.text!as NSString).replacingCharacters(in: range, with: string)

        searchAutocompleteEntriesWithSubstring(substring: substring)
        
        if let country = selectedCountry, string.lowercased() != country.name.common.lowercased(){
            selectedCountry = nil
        }
        return true // not sure about this - could be false

    }

    func searchAutocompleteEntriesWithSubstring(substring: String) {
        filteredCountries.removeAll()

        let region = regionTextField.text ?? ""
        
        if region.count > 0 {
            for country in countries {
                if country.region.lowercased() == region.lowercased() {
                    let currentCountry = country.name.common.lowercased()
                    let myString: NSString! = currentCountry as NSString
                    
                    let substringRange: NSRange! = myString.range(of: substring.lowercased())
                    
                    if (substringRange.location == 0 && filteredCountries.count < 3) {
                        filteredCountries.append(country)
                    }
                }
            }
            
            autocompleteTableView.reloadData()
        }
    }

}
