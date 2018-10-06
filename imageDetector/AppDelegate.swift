//
//  Copyright (c) 2018 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = uicolorFromHex(rgbValue: 0x1d2731)
        navigationBarAppearace.barTintColor = uicolorFromHex(rgbValue: 0x1d2731)
        navigationBarAppearace.titleTextAttributes = [NSAttributedStringKey.foregroundColor:uicolorFromHex(rgbValue: 0xffffff), NSAttributedStringKey.font: UIFont(name: "Yellowtail", size: 28.0)!]
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        
       
        
        FirebaseApp.configure()
        return true
    }
    
    func uicolorFromHex(rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
}

