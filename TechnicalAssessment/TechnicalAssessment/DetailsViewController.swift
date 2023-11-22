//
//  DetailsViewController.swift
//  TechnicalAssessment
//
//  Created by Nino on 11/22/23.
//

import UIKit

class DetailsViewController: UIViewController {
    
    private var country:Country!
    private var name:String!
    
    @IBOutlet weak var mainLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setLabelMessage()
    }
    
    public func setData(name: String, country: Country) {
        self.country = country
        self.name = name
        
        
    }
    
    func setLabelMessage() {
        var message = "Hi \(name!)\n\nYou are from\n\(country.region),\n\(country.name.common)\n\n"
        if let capital = country.capital?.first {
            message = "\(message)Your Capital City is:\n\(capital)"
        }
        mainLabel.text = message
    }


}
