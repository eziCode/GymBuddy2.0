//
//  NewTemplateCreationVC.swift
//  WorkoutPlanner
//
//  Created by Ezra Akresh on 7/6/23.
//

import UIKit

class NewTemplateCreationVC: UIViewController {
    
    var stringArr = [String]()
    
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var textInput: UITextField!

    weak var delegate: TemplateVCDelegate?
    
    var templateTitle: String?
    
    @IBAction func didTapSubmit(_ sender: Any) {
        if !stringArr.isEmpty {
            showTitleAlert()
        } else {
            showEmptyTemplateAlert()
        }
        
    }
    
    func showEmptyTemplateAlert() {
        let alertController = UIAlertController(title: "Empty Template", message: "", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alertController.addAction(dismissAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showTitleAlert() {
        let alert = UIAlertController(title: "Input Title", message: "", preferredStyle: UIAlertController.Style.alert)
            
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] (alertAction) in
            if let textField = alert.textFields?.first, let title = textField.text, !title.isEmpty {
                self?.delegate?.addButtonClicked(with: self?.stringArr, and: title)
                self!.stringArr.removeAll()
                self!.tableView.reloadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Enter title"
        }
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    @IBAction func didTapAddButton(_ sender: Any) {
        if let text = textInput.text, !text.isEmpty {
            stringArr.insert(text, at: 0)
            tableView.beginUpdates()
            tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .right)
            tableView.endUpdates()
            textInput.text = nil
        }
    }
    
    @IBAction func didTapDeleteButton(_ sender: UIButton) {
        let point = sender.convert(CGPoint.zero, to: tableView)
        guard let indexpath = tableView.indexPathForRow(at: point) else {return}
        stringArr.remove(at: indexpath.row)
        tableView.beginUpdates()
        tableView.deleteRows(at: [IndexPath(row: indexpath.row, section: 0)], with: .left)
        tableView.endUpdates()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}

extension NewTemplateCreationVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stringArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EditTableViewCell", for: indexPath) as? EditTableViewCell else {return UITableViewCell()}
        cell.labelName.text = stringArr[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

