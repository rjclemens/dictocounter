//
//  AppDelegate.swift
//  DictoCounter
//
//  Created by Raleigh Clemens on 3/20/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        print("Start ---> Finish launching.")
        return true
    }

    
    
    // MARK: UISceneSession Lifecycle

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when application: active->inactive state
        // i.e. bc incoming phone call or SMS message or when user quits application
        // and it transitions to the background state
        print("Active ---> Inactive.")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // save user data, invalidate timers, and store enough application state information
        // called @ applicationWillTerminate() when user quits
        print("Inactive ---> Background.")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        print("Background ---> Foreground.")
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        print("Inactive ---> Active.")
    }
    
    
    func applicationWillTerminate(_ application: UIApplication) {
            // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
            
            print("This app will be terminated.")
        }

    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

