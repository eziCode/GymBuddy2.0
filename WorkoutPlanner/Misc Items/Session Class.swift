//
//  Session Controller.swift
//  WorkoutPlanner
//
//  Created by Ezra Akresh on 10/17/23.
//

import Foundation
import RealmSwift
import UIKit

class Session: Object {
    @objc dynamic var sessionLength: String = "60"
    @objc dynamic var startTime: String = ""
    @objc dynamic var endTime: String = ""
}

