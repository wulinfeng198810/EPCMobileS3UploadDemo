//
//  AWSCognitoCredentialsProviderHelper.swift
//  EPCMobileS3UploadDemo
//
//  Created by Leo on 04/05/2017.
//  Copyright © 2017 Lio. All rights reserved.
//

import AWSCore

/*
 * Use the token method to communicate with your backend to get an
 * identityId and token.
 */
class DeveloperAuthenticatedIdentityProvider : AWSCognitoCredentialsProviderHelper {
    
    override func token() -> AWSTask<NSString> {
        //Write code to call your backend:
        //pass username/password to backend or some sort of token to authenticate user, if successful,
        //from backend call getOpenIdTokenForDeveloperIdentity with logins map containing "your.provider.name":"enduser.username"
        //return the identity id and token to client
        //You can use AWSTaskCompletionSource to do this asynchronously
        
        self.identityId = UserDefaults.standard.value(forKey: "aws_id") as? String
        let t = UserDefaults.standard.value(forKey: "aws_token")
        print("token: \(t)")
        let token = t as AnyObject
        
//        guard let token1 = token else {
//            return AWSTask(result: nil)
//        }
        
        self.identityId = "us-east-1:5f9bf9fb-937d-45e8-b715-7c9ac7d3f91d"
        let task = AWSTask(result: token)
        let task1 = task as! AWSTask<NSString>
        return task1
    }
}
