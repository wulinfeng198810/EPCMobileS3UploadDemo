//
//  AppDelegate.swift
//  EPCMobileS3UploadDemo
//
//  Created by Leo on 02/05/2017.
//  Copyright © 2017 Lio. All rights reserved.
//

import UIKit
import AWSCore
import AWSS3
import AWSCognito
import FMDB
import AFNetworking

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
//        AWSLogger.default().logLevel = .verbose

        let devAuth = DeveloperAuthenticatedIdentityProvider(regionType: .USEast1, identityPoolId: "us-east-1:e92bd5a8-717b-4af2-bf20-a518fbdb7dca", useEnhancedFlow: true, identityProviderManager:nil)
        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityProvider:devAuth)
        let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        
        EPCDirectory.shareInstance.deploy()
        
        EPCSqliteMangager.shareInstance.openDB()
        
        EPCAwsS3TaskManager.manager.networkMonitor(monitor: nil)
        
        
//        let cogCredent = AWSCognitoCredentialsProvider(regionType: .USEast1,
//                                                       identityPoolId: "us-east-1:e92bd5a8-717b-4af2-bf20-a518fbdb7dca")
//        
//        let aswConfig = AWSServiceConfiguration(region: .USEast1,
//                                                credentialsProvider: cogCredent)
//        
//        AWSServiceManager.default().defaultServiceConfiguration = aswConfig
        
        return true
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
        
        _ = EPCSqliteMangager.shareInstance.updateAllPhotoDBNotCompletedStateToFailedStateWhenAppTerminate()
    }


}

