//
//  GCGModesParser.swift
//  FlowApp
//
//  Created by Parth Adroja on 26/01/17.
//  Copyright © 2017 Parth Adroja. All rights reserved.
//

import Foundation

struct GCGModesParser {
    static let fromPoint	= "fromPoint"
    static let toPoint		= "toPoint"
    static let options	    = "options"
    static let title		= "title"
    static let type  		= "type"
    static let optionYes	= "yes"
    static let optionNo		= "no"
    static let end			= "end"
    
    var onSuccessfulEnd : (()->())?
    var dicMain : [String : Any] =  [:]
    var dicCurrentState : [String : Any] = [:]
    
    var isStepWithOption : Bool {
        return (dicCurrentState[GCGModesParser.options] != nil) ? true : false
    }
    
    
    var choices:[String] {
        if isStepWithOption {
            let choices = dicCurrentState[GCGModesParser.options] as! [String]
            return (choices.count > 5) ? Array(choices[0..<5]) : choices
        }
        return []
    }
    
    var currentStepText: String {
        return (dicCurrentState[GCGModesParser.title] ?? "") as! String
    }
    
    var currentStepType: String {
        return (dicCurrentState[GCGModesParser.type] ?? "") as! String
    }
    
    mutating func SetData(data:[String:Any]) {
        dicMain = data
        dicCurrentState = dicMain["D1"]! as! [String:Any]	
    }
    
    
    mutating func moveToStepNo() {
        checkForStepEnd()
        if let safeDicCurrentState = dicCurrentState[GCGModesParser.optionNo] as? [String:String] {
            let nextStep = safeDicCurrentState[GCGModesParser.toPoint]!
            if let safeDicCurrentState = dicMain[nextStep] as? [String:Any] {
                dicCurrentState = safeDicCurrentState
            }
        }
    }
    
    mutating func moveToStepYes() {
        if let safeDicCurrentState = dicCurrentState[GCGModesParser.optionYes] as? [String:String] {
            let nextStep = safeDicCurrentState[GCGModesParser.toPoint]!
            if let safeDicCurrentState = dicMain[nextStep] as? [String:Any] {
                dicCurrentState = safeDicCurrentState
            }
        }
        checkForStepEnd()
    }
    
    
    mutating func moveToStepChoice(choiceText:String) {
        if let safeDicCurrentState = dicCurrentState[choiceText] as? [String: String] {
            let nextStep = safeDicCurrentState[GCGModesParser.toPoint]!
            if let safeDicCurrentState = dicMain[nextStep] as? [String:Any] {
                dicCurrentState = safeDicCurrentState
            } else if let _ = dicCurrentState[GCGModesParser.title] as? String {
                if let prevStepText = dicCurrentState[GCGModesParser.fromPoint] as? String,
                    let fromStep = dicMain[prevStepText] as? [String:Any] {
                    dicCurrentState = fromStep
                }
            } else {
                checkForStepEnd()
            }
        } else {
            checkForStepEnd()
        }
    }
    
    mutating func moveToStepNext() {
        if let safeDicCurrentState = dicCurrentState[GCGModesParser.toPoint] as? String {
            dicCurrentState = dicMain[safeDicCurrentState]! as! [String : Any]
        } else if let __text = dicCurrentState[GCGModesParser.title] as? String, !__text.isEmpty  {
            if let nextStepText = dicCurrentState[GCGModesParser.toPoint] as? String,
                let toStep = dicMain[nextStepText] as? [String:Any] {
                dicCurrentState = toStep
            } else {
                checkForStepEnd()
            }
        } else {
            checkForStepEnd()
        }
        
        if let __text = dicCurrentState[GCGModesParser.title] as? String , !__text.isEmpty  {
            
        } else {
            checkForStepEnd()
        }
    }
    
    mutating func moveToStepPrevious() {
        if let safeDicCurrentState = dicCurrentState[GCGModesParser.fromPoint] as? String {
            dicCurrentState = dicMain[safeDicCurrentState]! as! [String : Any]
        } else if let __text  = dicCurrentState[GCGModesParser.title] as? String , !__text.isEmpty {
            if let prevStepText = dicCurrentState[GCGModesParser.fromPoint] as? String,
                let fromStep = dicMain[prevStepText] as? [String:Any] {
                dicCurrentState = fromStep
            } else {
                checkForStepEnd()
            }
        } else {
            checkForStepEnd()
        }
        
        if let __text = dicCurrentState[GCGModesParser.title] as? String , !__text.isEmpty  {
            
        } else {
            checkForStepEnd()
        }
    }
    
    mutating func reloadTroubleShoot() {
        dicCurrentState = dicMain[GCGModesParser.title]! as! [String : Any]
    }
    
    func checkForStepEnd()   {
        if let isEnd = dicCurrentState[GCGModesParser.end] as? Int {
            if isEnd == -1 {
                onSuccessfulEnd!()
            }
        }
    }
}
