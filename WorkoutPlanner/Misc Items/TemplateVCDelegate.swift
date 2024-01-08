//
//  TemplateVCDelegate.swift
//  WorkoutPlanner
//
//  Created by Ezra Akresh on 7/10/23.
//

import Foundation

protocol TemplateVCDelegate: AnyObject {
    func addButtonClicked(with exerciseStrings: [String]?, and templateTitle: String?)
}
