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
    static let id           = "id"
    static let exitType     = "exitType"

    var arrDicForPdf : [[String : String]] = []
    var dicStateMode : [String : String] = [:]
    var onSuccessfulEnd : (()->())?
    var dicMain : [String : Any] =  [:]
    var dicCurrentState : [String : Any] = [:]
    var arrQuestionaireSelected : [String] = []
    var arrOctagonSelected : [String] = []
    
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
    
    mutating func resetAllArrays() {
        arrDicForPdf.removeAll()
        dicStateMode.removeAll()
        arrQuestionaireSelected.removeAll()
        arrOctagonSelected.removeAll()
    }
    
    mutating func SetData(data:[String : Any]) {
        dicMain = data
        dicCurrentState = dicMain["D1"]! as! [String : Any]
    }
    
    mutating func saveState(key: String, value:String) {
        dicStateMode[key] = value
        print("dicStateMode === \(dicStateMode)")
    }
    
    mutating func saveDataForPdf(key: String, value: String) {
        arrDicForPdf.append([key : value])
        print("arrDicForPdf === \(arrDicForPdf)")
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
                saveDataForPdf(key: dicCurrentState[GCGModesParser.title] as! String, value: modeValue.no.rawValue)
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
                saveDataForPdf(key: dicCurrentState[GCGModesParser.title] as! String, value: modeValue.yes.rawValue)
                saveState(key: dicCurrentState[GCGModesParser.id] as! String, value: modeValue.yes.rawValue)
                dicCurrentState = safeDicCurrentState
                
            }
        } else if let currentChoices = dicCurrentState[GCGModesParser.options] as? [[String: Any]] {
            let toPoint = getToPointFromOptions(currentOptions: dicCurrentState[GCGModesParser.optionA] as! [[String: Any]])
            if let safeDicCurrentState = dicMain[toPoint] as? [String:Any] {
                saveDataForPdf(key: dicCurrentState[GCGModesParser.title] as! String, value: modeValue.yes.rawValue)
                saveState(key: dicCurrentState[GCGModesParser.id] as! String, value: modeValue.yes.rawValue)
                dicCurrentState = safeDicCurrentState
            }
            print(currentChoices)
        }
        checkForStepEnd()
    }
    
    mutating func removeValueForPPKey() {
        dicStateMode.removeValue(forKey: "PP1")
        dicStateMode.removeValue(forKey: "PP2")
        dicStateMode.removeValue(forKey: "PP3")
        dicStateMode.removeValue(forKey: "PP4")
    }
    
    mutating func moveToStepOK() {
        if let arrOptions = dicCurrentState[GCGModesParser.options] as? [[String : String]] {
            if arrOptions.count == 1 {
                let option = arrOptions.first!
                let toPoint = option[GCGModesParser.toPoint]!
                if let exitType = option[GCGModesParser.exitType]  {
                    removeValueForPPKey()
                    saveState(key: exitType, value: modeValue.yes.rawValue)
                }
                if let safeDicCurrentState = dicMain[toPoint] as? [String:Any] {
                    currentRootNode = toPoint
                    saveDataForPdf(key: dicCurrentState[GCGModesParser.title] as! String, value: modeValue.yes.rawValue)
                    saveState(key: dicCurrentState[GCGModesParser.id] as! String, value: modeValue.yes.rawValue)
                    dicCurrentState = safeDicCurrentState
                }
            } else if let currentChoices = dicCurrentState[GCGModesParser.options] as? [[String: Any]] {
                let toPoint = getToPointFromOptionsCheckingFromPoint(currentOptions: currentChoices)
                if let safeDicCurrentState = dicMain[toPoint] as? [String:Any] {
                    saveDataForPdf(key: dicCurrentState[GCGModesParser.title] as! String, value: modeValue.yes.rawValue)
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
        }  else if let currentChoices = dicCurrentState[GCGModesParser.options] as? [[String: Any]] {
            let toPoint = getToPointFromOptions(currentOptions: currentChoices)
            
            if let safeDicCurrentState = dicMain[toPoint] as? [String:Any] {
                saveDataForPdf(key: dicCurrentState[GCGModesParser.title] as! String, value: modeValue.yes.rawValue)
                saveState(key: dicCurrentState[GCGModesParser.id] as! String, value: modeValue.yes.rawValue)
                dicCurrentState = safeDicCurrentState
            }
            
            print(currentChoices)
            
        }

    }
    
    mutating func moveToStepChoice(choiceText:String) {
        if let safeDicCurrentState = dicCurrentState[choiceText] as? [String: String] {
            let nextStep = safeDicCurrentState[GCGModesParser.toPoint]!
            if let safeDicCurrentState = dicMain[nextStep] as? [String:Any] {
                saveDataForPdf(key: dicCurrentState[GCGModesParser.title] as! String, value: modeValue.yes.rawValue)
                saveState(key: dicCurrentState[GCGModesParser.id] as! String, value: modeValue.yes.rawValue)
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
                saveDataForPdf(key: dicCurrentState[GCGModesParser.title] as! String, value: modeValue.yes.rawValue)
                saveState(key: dicCurrentState[GCGModesParser.id] as! String, value: modeValue.yes.rawValue)
                dicCurrentState = safeDicCurrentState
            }
            
            print(currentChoices)
            
        }
         else {
            checkForStepEnd()
        }
    }
    
    func validateQustionnaire() -> (success:Bool, title:String?, optionID:String?) {
        
        if arrQuestionaireSelected.contains("Option1") && arrQuestionaireSelected.contains("Option3") {
            return (false, "It is not possible for options 1 and 3 to both be true. Please try again", nil)
        } else if arrQuestionaireSelected.contains("Option5") && arrQuestionaireSelected.count > 1 {
            return (false, "It is not possible for 'None of the above' and another option to both be true. Please try again", nil)
        } else if arrQuestionaireSelected.contains("Option1") && arrQuestionaireSelected.count == 1 {
            return (true, nil, "Option1")
        } else if arrQuestionaireSelected.contains("Option2") && arrQuestionaireSelected.count == 1 {
            return (true, nil, "Option2")
        } else if arrQuestionaireSelected.contains("Option3") && arrQuestionaireSelected.count == 1 {
            return (true, nil, "Option3")
        } else if arrQuestionaireSelected.contains("Option4") && arrQuestionaireSelected.count == 1 {
            return (true, nil, "Option4")
        } else if arrQuestionaireSelected.contains("Option5") && arrQuestionaireSelected.count == 1 {
            return (true, nil, "Option5")
        } else if arrQuestionaireSelected.contains("Option1") && arrQuestionaireSelected.contains("Option2") && arrQuestionaireSelected.count == 2 {
            return (true, nil, "Option1")
        } else if arrQuestionaireSelected.contains("Option2") && arrQuestionaireSelected.contains("Option3") && arrQuestionaireSelected.count == 2 {
            return (true, nil, "Option2")
        } else if arrQuestionaireSelected.contains("Option1") && arrQuestionaireSelected.contains("Option4") && arrQuestionaireSelected.count == 2 {
            return (true, nil, "Option1")
        } else if arrQuestionaireSelected.contains("Option2") && arrQuestionaireSelected.contains("Option4") && arrQuestionaireSelected.count == 2 {
            return (true, nil, "Option2")
        } else if arrQuestionaireSelected.contains("Option3") && arrQuestionaireSelected.contains("Option4") && arrQuestionaireSelected.count == 2 {
            return (true, nil, "Option3")
        } else if arrQuestionaireSelected.contains("Option1") && arrQuestionaireSelected.contains("Option2") && arrQuestionaireSelected.contains("Option4")  && arrQuestionaireSelected.count == 3 {
            return (true, nil, "Option1")
        } else if arrQuestionaireSelected.contains("Option3") && arrQuestionaireSelected.contains("Option2") && arrQuestionaireSelected.contains("Option4") && arrQuestionaireSelected.count == 3 {
            return (true, nil, "Option2")
        } else {
            return (false, "Something went wrong", nil)
        }
    }
    
    mutating func getToPointFromOptionsCheckingFromPoint(currentOptions: [[String : Any]]) -> String {
        var toPoint = ""
        for option in currentOptions {
            print("OPTIONSSSS===\(option)")
            let fromPoint = option["fromPoint"] as! String
            print(fromPoint)
            let nodeState = getNodeState(id: fromPoint)
            if nodeState {
                toPoint = option[GCGModesParser.toPoint] as! String
                if let exitType = option[GCGModesParser.exitType] as? String  {
                    removeValueForPPKey()
                    saveState(key: exitType, value: modeValue.yes.rawValue)
                }
            }
        }
        return toPoint
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
