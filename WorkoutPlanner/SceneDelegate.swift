//
//  SceneDelegate.swift
//  WorkoutPlanner
//
//  Created by Ezra Akresh on 6/2/23.
//

import UIKit
import RealmSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func isSessionActive() -> Bool {
        do {
            // Creating Realm instance
            let config = Realm.Configuration(schemaVersion: 2)
            let realm = try Realm(configuration: config)
            
            let objectsToDelete = realm.objects(Session.self)
            
            // Accessing end time
            guard let session = realm.objects(Session.self).first else {
                return false // No Session objects found
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy HH:mm" // Updated date format
            
            if let currentTime = dateFormatter.date(from: dateFormatter.string(from: Date())),
                let targetDate = dateFormatter.date(from: session.endTime) {
                
                return currentTime < targetDate
            }
            
            return false // Return false by default if there was an error in parsing the times.
        } catch {
            // Handle any Realm-related errors here
            print("Realm error: \(error)")
            return false
        }
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        if isSessionActive() {
            if let windowScene = scene as? UIWindowScene {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let tabBarController = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.mainTabBar) as? UITabBarController
                let window = UIWindow(windowScene: windowScene)
                window.rootViewController = tabBarController
                self.window = window
                window.makeKeyAndVisible()
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

