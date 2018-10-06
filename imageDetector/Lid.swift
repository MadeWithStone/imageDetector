//
//  Lid.swift
//  imageDetector
//
//  Created by Maxwell Stone on 10/4/18.
//  Copyright © 2018 Maxwell Stone. All rights reserved.
//

import Firebase
import Foundation

class Lid: NSObject {
    
    private var _landmarkName: String!
    private var _confidence: NSNumber!
    private var _entityId: String!
    private var _url: String!
    
    /*var LandmarkName: String!
    var Confidence: NSNumber!
    var EntityId: String!
    var Url: String!*/
    
    var landmarkName: String {
        return _landmarkName
    }
    
    var confidence: NSNumber {
        return _confidence
    }
    
    var entityId: String {
        return _entityId
    }
    
    var url: String! {
        return _url
    }
    
    init(landmarkName: String, confidence: NSNumber, entityId: String, url: String) {
        _landmarkName = landmarkName
        _confidence = confidence
        _entityId = entityId
        _url = url
    }
    
    init(landmarkData: Dictionary<String, AnyObject>) {
        
        if let landmarkName = landmarkData["landmarkName"] as? String {
            _landmarkName = landmarkName
        }
        
        if let confidence = landmarkData["confidence"] as? NSNumber {
            _confidence = confidence
        }
        
        if let entityId = landmarkData["entityId"] as? String {
            _entityId = entityId
        }
        
        if let url = landmarkData["url"] as? String {
            _url = url
        }
        
    }
    /*
     init(postTextD: UIImage) {
     PostText = postTextD
     }
     
     init(userNameD: String) {
     Username = userNameD
     }
     
     init(userImgD: UIImage) {
     UserImg = userImgD
     }
     
     init(starsD: Int) {
     Stars = starsD
     }
     
     init(dateD: String) {
     Date = dateD
     }
     
     init(keysD: Array<String>) {
     Keys = keysD
     }
     
     init(reportNumD: Int) {
     ReportNum = reportNumD
     }*/
    
    
}

