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
        
//        self.identityId = "us-east-1:5f9bf9fb-937d-45e8-b715-7c9ac7d3f91d"
//        return AWSTask(result: "eyJraWQiOiJ1cy1lYXN0LTExIiwidHlwIjoiSldTIiwiYWxnIjoiUlM1MTIifQ.eyJzdWIiOiJ1cy1lYXN0LTE6NWY5YmY5ZmItOTM3ZC00NWU4LWI3MTUtN2M5YWM3ZDNmOTFkIiwiYXVkIjoidXMtZWFzdC0xOmU5MmJkNWE4LTcxN2ItNGFmMi1iZjIwLWE1MThmYmRiN2RjYSIsImFtciI6WyJhdXRoZW50aWNhdGVkIiwiZXBjbW9iaWxlIiwiZXBjbW9iaWxlOnVzLWVhc3QtMTplOTJiZDVhOC03MTdiLTRhZjItYmYyMC1hNTE4ZmJkYjdkY2E6NzU5Il0sImlzcyI6Imh0dHBzOi8vY29nbml0by1pZGVudGl0eS5hbWF6b25hd3MuY29tIiwiZXhwIjoxNDkzOTczMjM1LCJpYXQiOjE0OTM4ODY4MzV9.VHH9wl8SNwub8PKboBZpG0xJtYh-7rHvDSgIN5FacLxT4FaggnoIK0crkS4HQkelIYCcMCbvT5qpOuu6MY9l7hBkfLEke1XdhGemQFXj7_oygoymB3PZFsDBzXYOUwYzmDpRWBS5Dg2IUQRcaAACv-DL3pW4hvZ_yPynjUj_aLvmpSML9bBpmqKKUYVvHA90cxr9-njQHwOOl9BA_SZBSFa__tLTImfpU0ARayhOWNxf2UuTKjs4L6p4TIJv6dPZvDDIDS76e4g_PNuCQ4Z7LnBFrn2Q_5wwXpZ4bEcF3BeTYh6daM_XkzxYTnlGNcY8P6D60AhukJTrYUGOrGLBZA")
    }
}
