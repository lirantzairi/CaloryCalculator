//
//  AppDelegate.swift
//  CaloryCalculator
//
//  Created by Liran Tzairi on 11/11/18.
//  Copyright © 2018 Liran Tzairi. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        FirebaseApp.configure()
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool
    {
        return GIDSignIn.sharedInstance().handle(url as URL?,
                                                 sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                                 annotation: options[UIApplication.OpenURLOptionsKey.annotation])
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

extension AppDelegate: GIDSignInDelegate
{
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?)
    {
        Preloader.show()
        
        if let error = error
        {
            print("Error \(error)")
            Preloader.hide()
            return
        }
        
        guard let authentication = user.authentication else
        {
            Preloader.hide()
            return
        }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        Auth.auth().signInAndRetrieveData(with: credential) { [weak self] authDataResult, error in
            if let error = error
            {
                print(error.localizedDescription)
                Preloader.hide()
                return
            }
            
            guard let sself = self, let authDataResult = authDataResult, let userInfo = sself.exctractUserInfo(from: authDataResult) else
            {
                Preloader.hide()
                return
            }
            
            NotificationCenter.default.post(name: .userDidSignInWithGoogle, object: self, userInfo: userInfo)
        }
    }
    
    private func exctractUserInfo(from authDataResult: AuthDataResult) -> [AnyHashable : Any]?
    {
        let uid = authDataResult.user.uid
        guard let name = authDataResult.user.displayName, let email = authDataResult.user.email, let isNewUser = authDataResult.additionalUserInfo?.isNewUser else
        {
            return nil
        }
        
        return [Constants.GoogleUserParams.uid : uid, Constants.GoogleUserParams.name: name, Constants.GoogleUserParams.email: email, Constants.GoogleUserParams.isNewUser: isNewUser]
    }
}

