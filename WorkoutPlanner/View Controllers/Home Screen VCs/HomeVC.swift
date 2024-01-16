//
//  ViewController.swift
//  WorkoutPlanner
//
//  Created by Ezra Akresh on 6/2/23.
//

import UIKit

class HomeVC: UIViewController, TemplateVCDelegate {
    
    var topAnchor: NSLayoutConstraint?
    
    var tapCounts: [Int] = []
    
    @IBOutlet weak var imageCollectionBackgroud: UIView!
    
    @IBOutlet weak var imageCollectionImageView: UIImageView!
    
    @IBOutlet weak var pushTemplate: UIView!
    @IBOutlet weak var pullTemplate: UIView!
    @IBOutlet weak var legsTemplate: UIView!
    @IBOutlet weak var newTemplateCreationMenu: UIView!
    
    var exerciseStrings2: [String] = []
    let customView = UIView(frame: CGRect(x: 0, y: 0, width: 393, height: 699))
    var homeScreenExercisesTableView = UITableView()
    var homeScreenSetsAndRepsTableView = UITableView()
    var customViewTopConstraint: NSLayoutConstraint?
    
    let secondsToDelay = 0.25
    
    @IBOutlet weak var TopAnchorPushTemplate: NSLayoutConstraint!
    
    @IBOutlet weak var TopAnchorPullTemplate: NSLayoutConstraint!
    
    @IBOutlet weak var TopAnchorLegsTemplate: NSLayoutConstraint!
    
    @IBOutlet weak var mainStackView: UIStackView!
    
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var PullButton: UIButton!
    
    @IBOutlet weak var LegsButton: UIButton!
    
    @IBOutlet weak var PushButton: UIButton!
    
    @IBOutlet var BackgroundView: UIView!
    
    
    @IBAction func didTapPushButton(_ sender: Any) {
        controlMenu(need: TopAnchorPushTemplate, and: pushTemplate)
    }

    @IBAction func didTapPullButton(_ sender: Any) {
        controlMenu(need: TopAnchorPullTemplate, and: pullTemplate)
        
    }
    @IBAction func didTapLegsButton(_ sender: Any) {
        controlMenu(need: TopAnchorLegsTemplate, and: legsTemplate)
        
    }
    @IBAction func didTapNewTemplate(_ sender: Any) {
        controlMenu(need: TopAnchorNewTemplateCreationMenu, and: newTemplateCreationMenu)
        
    }
    
    @IBOutlet weak var DimmerView: UIView!
    
    @IBOutlet weak var TopAnchorNewTemplateCreationMenu: NSLayoutConstraint!
    
    @IBOutlet weak var NewTemplateButton: UIButton!
    
    @IBOutlet weak var TemplateStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupStartingConfiguration()
        
        homeScreenExercisesTableView.dataSource = self
        homeScreenExercisesTableView.delegate = self
        homeScreenExercisesTableView.register(UITableViewCell.self, forCellReuseIdentifier: PrototypeCellID.exercisesCell)
        
        homeScreenSetsAndRepsTableView.dataSource = self
        homeScreenSetsAndRepsTableView.delegate = self
        homeScreenSetsAndRepsTableView.register(UITableViewCell.self, forCellReuseIdentifier: PrototypeCellID.setsAndRepsCell)
        
    }

    func addButtonClicked(with exerciseStrings: [String]?, and templateTitle: String?) {
        tapCounts = Array(repeating: 0, count: exerciseStrings!.count)
        exerciseStrings2 = exerciseStrings!
        customView.removeFromSuperview()
        TopAnchorNewTemplateCreationMenu.constant = view.frame.height
        UIView.animate(withDuration: 0.25, animations: {
            self.DimmerView.alpha = 0
            self.view.layoutIfNeeded()
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.tabBarController?.tabBar.isHidden = false
        }
        
        customView.translatesAutoresizingMaskIntoConstraints = false
        customView.backgroundColor = UIColor(red: 234/255, green: 236/255, blue: 237/255, alpha: 1)
        BackgroundView.addSubview(customView)
        customViewTopConstraint = customView.topAnchor.constraint(equalTo: view.superview!.topAnchor, constant: view.frame.height)
        customViewTopConstraint?.isActive = true
        NSLayoutConstraint.activate([
            customView.heightAnchor.constraint(equalToConstant: ((699/852)*view.frame.height)),
            customView.leadingAnchor.constraint(equalTo: view.superview!.leadingAnchor),
            customView.trailingAnchor.constraint(equalTo: view.superview!.trailingAnchor),
        ])
        homeScreenExercisesTableView.translatesAutoresizingMaskIntoConstraints = false
        customView.addSubview(homeScreenExercisesTableView)
        NSLayoutConstraint.activate([
            homeScreenExercisesTableView.leadingAnchor.constraint(equalTo: customView.leadingAnchor),
            homeScreenExercisesTableView.bottomAnchor.constraint(equalTo: customView.bottomAnchor),
            homeScreenExercisesTableView.topAnchor.constraint(equalTo: customView.topAnchor),
            homeScreenExercisesTableView.widthAnchor.constraint(equalToConstant: ((269/393)*customView.frame.width))
        ])
        homeScreenSetsAndRepsTableView.translatesAutoresizingMaskIntoConstraints = false
        customView.addSubview(homeScreenSetsAndRepsTableView)
        NSLayoutConstraint.activate([
            homeScreenSetsAndRepsTableView.leadingAnchor.constraint(equalTo: homeScreenExercisesTableView.trailingAnchor, constant: ((10/393)*customView.frame.width)),
            homeScreenSetsAndRepsTableView.bottomAnchor.constraint(equalTo: customView.bottomAnchor),
            homeScreenSetsAndRepsTableView.topAnchor.constraint(equalTo: customView.topAnchor),
            homeScreenSetsAndRepsTableView.trailingAnchor.constraint(equalTo: customView.safeAreaLayoutGuide.trailingAnchor)
        ])
        let templateButton = UIButton()
        //Add label
        templateButton.setTitle(templateTitle, for: .normal)
        templateButton.setTitleColor(UIColor.black, for: .normal)
        templateButton.layer.borderColor = CGColor(red: 235, green: 235, blue: 235, alpha: 0.25)
        templateButton.layer.borderWidth = 2
        templateButton.layer.cornerRadius = 5
        templateButton.addTarget(self, action: #selector(didTapTemplateButton), for: .touchUpInside)
        TemplateStackView.addArrangedSubview(templateButton)
        homeScreenExercisesTableView.reloadData()
        homeScreenSetsAndRepsTableView.reloadData()
    }

    @objc func didTapTemplateButton() {
        customViewTopConstraint?.constant = view.frame.height - customView.frame.height
        DimmerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissNewTemplate)))
        UIView.animate(withDuration: 0.25, animations: {
            self.DimmerView.alpha = 0.6
            self.tabBarController?.tabBar.isHidden = true
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func dismissNewTemplate() {
        customViewTopConstraint?.constant = view.frame.height
        UIView.animate(withDuration: 0.25, animations: {
            self.DimmerView.alpha = 0
            self.view.layoutIfNeeded()
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.tabBarController?.tabBar.isHidden = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let templateVC = segue.destination as? NewTemplateCreationVC {
            templateVC.delegate = self
        }
    }

    func setupStartingConfiguration() {
        imageCollectionBackgroud.translatesAutoresizingMaskIntoConstraints = false
        imageCollectionImageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageCollectionBackgroud.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapImageCollection)))
        imageCollectionImageView.isUserInteractionEnabled = true
        imageCollectionImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapImageCollection)))
        
        NSLayoutConstraint.activate([
            //Menu constraints
            newTemplateCreationMenu.heightAnchor.constraint(equalToConstant: ((699/852)*view.frame.height)),
            pushTemplate.heightAnchor.constraint(equalToConstant: ((699/852)*view.frame.height)),
            pullTemplate.heightAnchor.constraint(equalToConstant: ((699/852)*view.frame.height)),
            legsTemplate.heightAnchor.constraint(equalToConstant: ((699/852)*view.frame.height)),
            
            //Premade template button constraints
            PushButton.heightAnchor.constraint(equalToConstant: (40/852)*view.frame.height),
            LegsButton.heightAnchor.constraint(equalToConstant: (40/852)*view.frame.height),
            PullButton.heightAnchor.constraint(equalToConstant: (40/852)*view.frame.height),
            PushButton.widthAnchor.constraint(equalToConstant: (213.67/393)*view.frame.width),
            LegsButton.widthAnchor.constraint(equalToConstant: (213.67/393)*view.frame.width),
            PullButton.widthAnchor.constraint(equalToConstant: (213.67/393)*view.frame.width),
            
            //Image Collection Background
            imageCollectionBackgroud.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageCollectionBackgroud.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: (50/852)*view.frame.height),
            imageCollectionBackgroud.widthAnchor.constraint(equalToConstant: (361/393)*view.frame.width),
            imageCollectionBackgroud.heightAnchor.constraint(equalToConstant: (151/852)*view.frame.height),
            
            //Image Collection Button
            imageCollectionImageView.centerXAnchor.constraint(equalTo: imageCollectionBackgroud.centerXAnchor),
            imageCollectionImageView.centerYAnchor.constraint(equalTo: imageCollectionBackgroud.centerYAnchor),
            imageCollectionImageView.widthAnchor.constraint(equalToConstant: (168/393)*view.frame.width),
            imageCollectionImageView.heightAnchor.constraint(equalToConstant: (81/852)*view.frame.height),
            
            //Main stack view constaints
            mainStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        topView.roundCornerView(corners: [.bottomLeft, .bottomRight], radius: (20/119)*topView.frame.height)
        imageCollectionBackgroud.layer.cornerRadius = 30
        PullButton.layer.borderColor = CGColor(red: 235, green: 235, blue: 235, alpha: 0.25)
        LegsButton.layer.borderColor = CGColor(red: 235, green: 235, blue: 235, alpha: 0.25)
        PushButton.layer.borderColor = CGColor(red: 235, green: 235, blue: 235, alpha: 0.25)
        PushButton.layer.borderColor = CGColor(red: 235, green: 235, blue: 235, alpha: 0.25)
        PullButton.layer.borderWidth = 2
        LegsButton.layer.borderWidth = 2
        PushButton.layer.borderWidth = 2
        PullButton.layer.cornerRadius = 5
        LegsButton.layer.cornerRadius = 5
        PushButton.layer.cornerRadius = 5
        NewTemplateButton.layer.cornerRadius = 5
        PullButton.contentHorizontalAlignment = .center
        LegsButton.contentHorizontalAlignment = .center
        PushButton.contentHorizontalAlignment = .center
        NewTemplateButton.contentHorizontalAlignment = .center
    }
    
    @objc func handleDismiss() {
        self.topAnchor!.constant = view.frame.height
        UIView.animate(withDuration: 0.25, animations: {
            self.DimmerView.alpha = 0
            self.view.layoutIfNeeded()
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.tabBarController?.tabBar.isHidden = false
        }

    }
    func controlMenu(need topAnchor: NSLayoutConstraint,and template: UIView) {
        DimmerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleDismiss)))
        self.topAnchor = topAnchor
        topAnchor.constant = view.frame.height - template.frame.height
        UIView.animate(withDuration: 0.25, animations: {
            self.DimmerView.alpha = 0.6
            self.tabBarController?.tabBar.isHidden = true
            self.view.layoutIfNeeded()
        })
        hideKeyboardWhenTappedAround()
    }
    
    func splitStringAtFirstNumber(_ inputString: String) -> String? {
        let decimalDigits = CharacterSet.decimalDigits
        guard let range = inputString.rangeOfCharacter(from: decimalDigits) else {
            // If no number is found, return nil
            return nil
        }
        let index = range.lowerBound
        let secondPart = String(inputString.suffix(from: index))
        return secondPart
    }

}

extension HomeVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tapCounts[indexPath.row] = (tapCounts[indexPath.row] + 1) % 3
        homeScreenExercisesTableView.reloadRows(at: [indexPath], with: .none)
        homeScreenSetsAndRepsTableView.reloadRows(at: [indexPath], with: .none)
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

extension HomeVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exerciseStrings2.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == homeScreenExercisesTableView {
            let uuid = UUID()
            let uuidString = uuid.uuidString
            let key = exerciseStrings2[indexPath.row]
            let keyx = splitStringAtFirstNumber(key) ?? uuidString
            let modifiedKey = key.replacingOccurrences(of: keyx, with: "")
            let exercisesCell = homeScreenExercisesTableView.dequeueReusableCell(withIdentifier: PrototypeCellID.exercisesCell, for: indexPath)
            exercisesCell.textLabel?.text = modifiedKey
            exercisesCell.backgroundColor = backgroundColorForRow(tapCounts[indexPath.row])
            
            return exercisesCell
        } else if tableView == homeScreenSetsAndRepsTableView {
            let key = exerciseStrings2[indexPath.row]
            let setsAndReps = splitStringAtFirstNumber(key) ?? "N/A"
            let setsAndRepsCell = homeScreenSetsAndRepsTableView.dequeueReusableCell(withIdentifier: PrototypeCellID.setsAndRepsCell, for: indexPath)
            setsAndRepsCell.textLabel?.text = setsAndReps
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
