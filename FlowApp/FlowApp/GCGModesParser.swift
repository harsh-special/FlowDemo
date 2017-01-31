//
//  GCGModesParser.swift
//  FlowApp
//
//  Created by Parth Adroja on 26/01/17.
//  Copyright © 2017 Parth Adroja. All rights reserved.
//

import Foundation

enum modeValue : String {
    case yes = "yes"
    case no  = "no"
}

struct GCGModesParser {
    static let fromPoint	= "fromPoint"
    static let toPoint		= "toPoint"
    static let options	    = "options"
    static let title		= "title"
    static let type  		= "type"
    static let optionA	    = "optionA"
    static let optionB		= "optionB"
    static let end			= "exit"
    static let MCQues1      = "PP1"
    static let MCQues2      = "PP2"
    static let MCQues3      = "PP3"
    static let MCQues4      = "PP4"
    static let MCQues5      = "PP5"
    static let id           = "id"

    var dicStateMode : [String : String] = [:]
    var onSuccessfulEnd : (()->())?
    var dicMain : [String : Any] =  [:]
    var dicCurrentState : [String : Any] = [:]
    
    var isStepWithOption : Bool {
        return (dicCurrentState[GCGModesParser.options] != nil) ? true : false
    }
    
    
    var choices:[[String : Any]] {
        if isStepWithOption {
            let choices = dicCurrentState[GCGModesParser.options] as! [[String : Any]]
            return (choices.count > 5) ? Array(choices[0..<5]) : choices 
        }
        return []
    }
    
    var currentRootNode: String = ""
    
    var currentNodeID : String {
        return dicCurrentState[GCGModesParser.id] as! String
    }
    
    var currentStepText: String {
        return (dicCurrentState[GCGModesParser.title] ?? "") as! String
    }
    
    var currentStepType: String {
        return (dicCurrentState[GCGModesParser.type] ?? "") as! String
    }
    
    mutating func SetData(data:[String : Any]) {
        dicMain = data
        dicCurrentState = dicMain["D1"]! as! [String : Any]
    }
    
    mutating func saveState(key: String, value:String) {
        dicStateMode[key] = value
        print("dicStateMode === \(dicStateMode)")
    }
    
    func getNodeState(id:String) -> Bool {
        return dicStateMode[id] == "yes" ? true : false
    }
    

    
    mutating func moveToStepNo() {
        checkForStepEnd()
        if let safeDicCurrentState = dicCurrentState[GCGModesParser.optionB] as? [String : String] {
            let nextStep = safeDicCurrentState[GCGModesParser.toPoint]!
            if let safeDicCurrentState = dicMain[nextStep] as? [String:Any] {
                currentRootNode = nextStep

                saveState(key: dicCurrentState[GCGModesParser.id] as! String, value: modeValue.no.rawValue)
                dicCurrentState = safeDicCurrentState
            }
        }
    }
    
    
    mutating func moveToStepYes() {
        if let safeDicCurrentState = dicCurrentState[GCGModesParser.optionA] as? [String:String] {
            let nextStep = safeDicCurrentState[GCGModesParser.toPoint]!
            if let safeDicCurrentState = dicMain[nextStep] as? [String:Any] {
                currentRootNode = nextStep
                
                saveState(key: dicCurrentState[GCGModesParser.id] as! String, value: modeValue.yes.rawValue)
                dicCurrentState = safeDicCurrentState
                
            }
        }
        checkForStepEnd()
    }
    
    mutating func moveToStepOK() {
        if let arrOptions = dicCurrentState[GCGModesParser.options] as? [[String : String]] {
            
            if arrOptions.count == 1 {
                let option = arrOptions.first!
                let toPoint = option[GCGModesParser.toPoint]!
                
                if let safeDicCurrentState = dicMain[toPoint] as? [String:Any] {
                    currentRootNode = toPoint
                    saveState(key: dicCurrentState[GCGModesParser.id] as! String, value: modeValue.yes.rawValue)
                    dicCurrentState = safeDicCurrentState
                }
                
            }
            
            /*
            if let toPoint = safeDicCurrentState[GCGModesParser.toPoint] {
                if let safeDicCurrentState = dicMain[toPoint] as? [String:Any] {
                    currentRootNode = toPoint
                    saveState(key: dicCurrentState[GCGModesParser.id] as! String, value: modeValue.yes.rawValue)
                    dicCurrentState = safeDicCurrentState
                }
            }
            */
        }
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
        } else if let currentChoices = dicCurrentState[choiceText] as? [[String: Any]] {
            let toPoint = getToPointFromOptions(currentOptions: currentChoices)
            
            if let safeDicCurrentState = dicMain[toPoint] as? [String:Any] {
                dicCurrentState = safeDicCurrentState
            }
            
            print(currentChoices)
            
        }
        else {
            checkForStepEnd()
        }
    }
    
    
    func getToPointFromOptions(currentOptions: [[String : Any]]) -> String {
        var toPoint = ""
        for option in currentOptions {
            let arrPositive = option["positive"] as! [String]
            let arrNegative = option["negative"] as! [String]

            let arrPositiveValues = arrPositive.map{ return getNodeState(id: $0) }
            let arrNegativeValues = arrNegative.map{ return getNodeState(id: $0) }

            let isAllPositive = !arrPositiveValues.contains(false)
            let isAllNegative = !arrNegativeValues.contains(true)

            
            if arrPositiveValues.count > 0 && arrNegativeValues.count > 0 {

                print("arrPositive === \(arrPositive)")
                print("negative === \(arrNegative)")

                print("arrPositiveValues === \(arrPositiveValues)")
                print("arrNegativeValues === \(arrNegativeValues)")
                
                
                if isAllNegative && isAllPositive {
                    toPoint = option[GCGModesParser.toPoint] as! String
                }
                
                
            } else if arrNegative.count == 0 {
                

                if isAllPositive {
                    toPoint = option[GCGModesParser.toPoint] as! String
                }
                
                
            } else if arrPositive.count == 0 {
                
                if isAllNegative {
                    toPoint = option[GCGModesParser.toPoint] as! String
                }
                
            } else {
                
                toPoint = option[GCGModesParser.toPoint] as! String
            }
            
            
        }
        
        return toPoint
    }

    
    
//    func getToPointFromOptions(currentOptions: [[String : Any]]) -> String {
//        var toPoint = ""
//        for option in currentOptions {
//            let arrPositive = option["positive"] as! [String]
//            let arrNegative = option["negative"] as! [String]
//            
//            
//            let arrPositiveValues = arrPositive.map{ return getNodeState(id: $0) }
//            let arrNegativeValues = arrNegative.map{ return getNodeState(id: $0) }
//            
//            let postiveResult = arrPositiveValues.contains(false)
//            let negativeResult = arrNegativeValues.contains(true)
//
//            if !postiveResult && !negativeResult {
//                
//            } else {
//                toPoint = option[GCGModesParser.toPoint] as! String
//            }
//            
//        }
// 
//        return toPoint
//    }
    
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
    
//    mutating func moveToStepPrevious() {
//        if let safeDicCurrentState = dicCurrentState[GCGModesParser.fromPoint] as? String {
//            dicCurrentState = dicMain[safeDicCurrentState]! as! [String : Any]
//        } else if let __text  = dicCurrentState[GCGModesParser.title] as? String , !__text.isEmpty {
//            if let prevStepText = dicCurrentState[GCGModesParser.fromPoint] as? String,
//                let fromStep = dicMain[prevStepText] as? [String:Any] {
//                dicCurrentState = fromStep
//            } else {
//                checkForStepEnd()
//            }
//        } else {
//            checkForStepEnd()
//        }
//        
//        if let __text = dicCurrentState[GCGModesParser.title] as? String , !__text.isEmpty  {
//            
//        } else {
//            checkForStepEnd()
//        }
//    }
    
//    mutating func reloadTroubleShoot() {
//        dicCurrentState = dicMain[GCGModesParser.title]! as! [String : Any]
//    }
    
    func checkForStepEnd()   {
        if let isEnd = dicCurrentState[GCGModesParser.toPoint] as? Int {
            if isEnd == -1 {
                onSuccessfulEnd!()
            }
        }
    }
}
