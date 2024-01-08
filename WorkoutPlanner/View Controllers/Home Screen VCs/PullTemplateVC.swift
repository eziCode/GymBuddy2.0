//
//  PullTemplateVC.swift
//  WorkoutPlanner
//
//  Created by Ezra Akresh on 6/19/23.
//

import UIKit

class PullTemplateVC: UIViewController {

    var pullExercises: Dictionary = ["Lat Pulldown": "3x10",
                                     "Bicep Curls": "3x8",
                                     "Preacher Curls": "3x6",
                                     "Deadlifts": "2x12"]
    
    var tapCounts: [Int] = []
    
    @IBOutlet var exercisesTableView: UITableView!
    
    @IBOutlet var setsAndRepsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        exercisesTableView.delegate = self
        exercisesTableView.dataSource = self

        setsAndRepsTableView.delegate = self
        setsAndRepsTableView.dataSource = self
        
        tapCounts = Array(repeating: 0, count: pullExercises.count)
    }
    
}


extension PullTemplateVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tapCounts[indexPath.row] = (tapCounts[indexPath.row] + 1) % 3
        exercisesTableView.reloadRows(at: [indexPath], with: .none)
        setsAndRepsTableView.reloadRows(at: [indexPath], with: .none)
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

extension PullTemplateVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pullExercises.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == exercisesTableView {
            let keys = Array(pullExercises.keys)
            let key = keys[indexPath.row]
            let exercisesCell = tableView.dequeueReusableCell(withIdentifier: PrototypeCellID.exercisesCell, for: indexPath)
            
            exercisesCell.textLabel?.text = key
            exercisesCell.backgroundColor = backgroundColorForRow(tapCounts[indexPath.row])
            
            return exercisesCell
        } else if tableView == setsAndRepsTableView {
            let setsAndRepsCell = setsAndRepsTableView.dequeueReusableCell(withIdentifier: PrototypeCellID.setsAndRepsCell, for: indexPath)
            
            let values = Array(pullExercises.values)
            let value = values[indexPath.row]
            
            setsAndRepsCell.textLabel?.text = value
            setsAndRepsCell.textLabel?.textAlignment = .center
            setsAndRepsCell.backgroundColor = backgroundColorForRow(tapCounts[indexPath.row])
            
            return setsAndRepsCell
        } else {
            fatalError("Invalid Table")
        }
        
    }
    
    func backgroundColorForRow(_ tapCount: Int) -> UIColor {
           switch tapCount {
           case 0:
               return UIColor.white
           case 1:
               return UIColor(red: 255/255, green: 255/255, blue: 0, alpha: 0.5)
           case 2:
               return UIColor(red: 0, green: 255/255, blue: 0, alpha: 0.5)
           default:
               return .white
           }
    }
    
}
