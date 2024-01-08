//
//  PushTemplateVC.swift
//  WorkoutPlanner
//
//  Created by Ezra Akresh on 6/19/23.
//

import UIKit

class PushTemplateVC: UIViewController {

    var tapCounts: [Int] = []
    
    var pushExercises: Dictionary = ["Bench Press": "3x10",
                                    "Incline Dumbell Press": "3x8",
                                    "Cable Tricep Extensions": "3x6",
                                    "Cable Flys": "2x10"]
    
    @IBOutlet var exercisesTableView: UITableView!
    
    @IBOutlet var setsAndRepsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        exercisesTableView.delegate = self
        exercisesTableView.dataSource = self
        
        setsAndRepsTableView.delegate = self
        setsAndRepsTableView.dataSource = self
        
        tapCounts = Array(repeating: 0, count: pushExercises.count)
    }

    
    
}

extension PushTemplateVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tapCounts[indexPath.row] = (tapCounts[indexPath.row] + 1) % 3
        exercisesTableView.reloadRows(at: [indexPath], with: .none)
        setsAndRepsTableView.reloadRows(at: [indexPath], with: .none)
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

extension PushTemplateVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pushExercises.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == exercisesTableView {
            let keys = Array(pushExercises.keys)
            let key = keys[indexPath.row]
            let exercisesCell = exercisesTableView.dequeueReusableCell(withIdentifier: PrototypeCellID.exercisesCell, for: indexPath)
            
            exercisesCell.textLabel?.text = key
            exercisesCell.backgroundColor = backgroundColorForRow(tapCounts[indexPath.row])
            
            return exercisesCell
        } else if tableView == setsAndRepsTableView {
            
            let setsAndRepsCell = setsAndRepsTableView.dequeueReusableCell(withIdentifier: PrototypeCellID.setsAndRepsCell, for: indexPath)
            
            let values = Array(pushExercises.values)
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
