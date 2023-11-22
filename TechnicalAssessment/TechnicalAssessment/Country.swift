//
//  File.swift
//  TechnicalAssessment
//
//  Created by Nino on 11/22/23.
//

import Foundation

struct Country:Codable {
    var name:Name
    var region:String
    var capital:[String]?
}

struct Name:Codable {
    var common:String
    var official:String
    
}
