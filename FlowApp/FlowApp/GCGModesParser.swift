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
    
    // MARK: - When no button is tapped on diamond
    
    mutating func moveToStepNo() {
        checkForStepEnd()
        
        // IF direct dictionary of toPoint
        if let safeDicCurrentState = dicCurrentState[GCGModesParser.optionB] as? [String : String] {
            let nextStep = safeDicCurrentState[GCGModesParser.toPoint]!
            if let safeDicCurrentState = dicMain[nextStep] as? [String:Any] {
                currentRootNode = nextStep
                saveDataForPdf(key: dicCurrentState[GCGModesParser.title] as! String, value: modeValue.no.rawValue)
                saveState(key: dicCurrentState[GCGModesParser.id] as! String, value: modeValue.no.rawValue)
                dicCurrentState = safeDicCurrentState
            }
        }
            
            // IF Array of options then get toPoint which is true
        else if let currentChoices = dicCurrentState[GCGModesParser.options] as? [[String: Any]] {
            if let toPoint = getToPointFromOptions(currentOptions: dicCurrentState[GCGModesParser.optionB] as! [[String: Any]]) {
                if let safeDicCurrentState = dicMain[toPoint] as? [String:Any] {
                    saveDataForPdf(key: dicCurrentState[GCGModesParser.title] as! String, value: modeValue.no.rawValue)
                    saveState(key: dicCurrentState[GCGModesParser.id] as! String, value: modeValue.no.rawValue)
                    dicCurrentState = safeDicCurrentState
                }
                print(currentChoices)
            }
        }
    }
    
    // MARK: - When yes button is tapped on diamond
    
    mutating func moveToStepYes() -> (success:Bool, title:String?, optionID:String?) {
        
        if let currenNode = dicCurrentState[GCGModesParser.id] as? String {
            if currenNode == "P51_D12" {
                if isStateSavedFor(key: "M1_D7") {
                    let value = getNodeState(id: "M1_D7")
                    if !value {
                        return (false, "It's not possible to select No previously at M1_D7 and now select Yes at P51_D12.  Please try again and select No.", nil)
                    }
                }
            }
        }
        
        
        // IF direct dictionary of toPoint
        if let safeDicCurrentState = dicCurrentState[GCGModesParser.optionA] as? [String:String] {
            let nextStep = safeDicCurrentState[GCGModesParser.toPoint]!
            if let safeDicCurrentState = dicMain[nextStep] as? [String:Any] {
                currentRootNode = nextStep
                saveDataForPdf(key: dicCurrentState[GCGModesParser.title] as! String, value: modeValue.yes.rawValue)
                saveState(key: dicCurrentState[GCGModesParser.id] as! String, value: modeValue.yes.rawValue)
                dicCurrentState = safeDicCurrentState
                
            }
        }
            
            // IF Array of options then get toPoint which is true
        else if let currentChoices = dicCurrentState[GCGModesParser.options] as? [[String: Any]] {
            if let toPoint = getToPointFromOptions(currentOptions: dicCurrentState[GCGModesParser.optionA] as! [[String: Any]]) {
                if let safeDicCurrentState = dicMain[toPoint] as? [String:Any] {
                    saveDataForPdf(key: dicCurrentState[GCGModesParser.title] as! String, value: modeValue.yes.rawValue)
                    saveState(key: dicCurrentState[GCGModesParser.id] as! String, value: modeValue.yes.rawValue)
                    dicCurrentState = safeDicCurrentState
                }
                print(currentChoices)
            }
        }
        checkForStepEnd()
        
        return (true,nil,nil)
    }
    
    // MARK: - When OK button is tapped on OVAL, HEXAGON
    
    mutating func moveToStepOK() {
        
        // IF Array of options then get toPoint which is true
        if let arrOptions = dicCurrentState[GCGModesParser.options] as? [[String : String]] {
            
            // IF only one value then take first toPoint
            if arrOptions.count == 1 {
                let option = arrOptions.first!
                let toPoint = option[GCGModesParser.toPoint]!
                
                // Store exit type but clear all others before.
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
            }
                
                // If more than one element then check condition which is true and takes its ToPoint
            else if let currentChoices = dicCurrentState[GCGModesParser.options] as? [[String: Any]] {
                if let toPoint = getToPointFromOptionsCheckingFromPoint(currentOptions: currentChoices) {
                    if let safeDicCurrentState = dicMain[toPoint] as? [String:Any] {
                        saveDataForPdf(key: dicCurrentState[GCGModesParser.title] as! String, value: modeValue.yes.rawValue)
                        saveState(key: dicCurrentState[GCGModesParser.id] as! String, value: modeValue.yes.rawValue)
                        dicCurrentState = safeDicCurrentState
                    }
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
            
            // IF Array of options but with positive and negative then get toPoint which is true
        else if let currentChoices = dicCurrentState[GCGModesParser.options] as? [[String: Any]] {
            if let toPoint = getToPointFromOptionsCheckingFromPoint(currentOptions: currentChoices), toPoint != "" {
                if let safeDicCurrentState = dicMain[toPoint] as? [String:Any] {
                    saveDataForPdf(key: dicCurrentState[GCGModesParser.title] as! String, value: modeValue.yes.rawValue)
                    saveState(key: dicCurrentState[GCGModesParser.id] as! String, value: modeValue.yes.rawValue)
                    dicCurrentState = safeDicCurrentState
                }
            } else if let toPoint = getToPointFromOptions(currentOptions: currentChoices) {
                if let safeDicCurrentState = dicMain[toPoint] as? [String:Any] {
                    saveDataForPdf(key: dicCurrentState[GCGModesParser.title] as! String, value: modeValue.yes.rawValue)
                    saveState(key: dicCurrentState[GCGModesParser.id] as! String, value: modeValue.yes.rawValue)
                    dicCurrentState = safeDicCurrentState
                }
            }
        }
    }
    
    // MARK: - When Next button is tapped on redRectangle, yellowHexa
    
    mutating func moveToStepChoice(choiceText:String) {
        
        // If dictionary
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
        }
            
            // If Array
        else if let currentChoices = dicCurrentState[choiceText] as? [[String: Any]] {
            if let toPoint = getToPointFromOptions(currentOptions: currentChoices) {
                if let safeDicCurrentState = dicMain[toPoint] as? [String:Any] {
                    saveDataForPdf(key: dicCurrentState[GCGModesParser.title] as! String, value: modeValue.yes.rawValue)
                    saveState(key: dicCurrentState[GCGModesParser.id] as! String, value: modeValue.yes.rawValue)
                    dicCurrentState = safeDicCurrentState
                }
                print(currentChoices)
            }
        }
        else {
            checkForStepEnd()
        }
    }
    
    // MARK: - Helper Methods
    
    mutating func removeValueForPPKey() {
        dicStateMode.removeValue(forKey: "PP1")
        dicStateMode.removeValue(forKey: "PP2")
        dicStateMode.removeValue(forKey: "PP3")
        dicStateMode.removeValue(forKey: "PP4")
        dicStateMode.removeValue(forKey: "M1_PP1")
        dicStateMode.removeValue(forKey: "M1_PP2")
        dicStateMode.removeValue(forKey: "M1_PP3")
        dicStateMode.removeValue(forKey: "M1_PP4")
        dicStateMode.removeValue(forKey: "M3_PP1")
        dicStateMode.removeValue(forKey: "M3_PP2")
        dicStateMode.removeValue(forKey: "M3_PP3")
        dicStateMode.removeValue(forKey: "M3_PP4")
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
    
    func validateOptionsForOctagon(optionSelected: String) -> (success:Bool, title:String?, optionID:String?) {
        if arrQuestionaireSelected.contains("Option3") {
            if let currentNode = dicCurrentState[GCGModesParser.id] as? String {
                if currentNode == "M1_OC2" || currentNode == "OC2" || currentNode == "M3_OC2" {
                    if optionSelected == "optionA" {
                        return (false, "Since you've selected option 3, it's not possible to have A option.  Please try again.", nil)
                    }
                }
            }
            return (true, nil, optionSelected)
        }
        else {
            return (true, nil, optionSelected)
        }
    }
    
    mutating func getToPointFromOptionsCheckingFromPoint(currentOptions: [[String : Any]]) -> String? {
        var toPoint = ""
        for option in currentOptions {
            print("OPTIONSSSS===\(option)")
            if let fromPoint = option["fromPoint"] as? String {
                print(fromPoint)
                let nodeState = isStateSavedFor(key: fromPoint)
                if nodeState {
                    toPoint = option[GCGModesParser.toPoint] as! String
                    if let exitType = option[GCGModesParser.exitType] as? String  {
                        removeValueForPPKey()
                        saveState(key: exitType, value: modeValue.yes.rawValue)
                    }
                }
            } else if let fromPoint = option["fromPoint"] as? [String] {
                print(fromPoint)
                let nodeState =  isArrStateSavedFor(keys: fromPoint)
                if nodeState {
                    toPoint = option[GCGModesParser.toPoint] as! String
                    if let exitType = option[GCGModesParser.exitType] as? String  {
                        removeValueForPPKey()
                        saveState(key: exitType, value: modeValue.yes.rawValue)
                    }
                }
            }
            
        }
        return toPoint
    }
    
    func isStateSavedFor(key: String) -> Bool {
        if dicStateMode[key] != nil {
            return true
        } else {
            return false
        }
    }
    
    func isArrStateSavedFor(keys: [String]) -> Bool {
        let result = keys.reduce(true, { $0 ? ([String] (dicStateMode.keys)).contains($1) : $0 })
        return result
    }
    
    mutating func getToPointFromOptions(currentOptions: [[String : Any]]) -> String? {
        var toPoint: String?
        for option in currentOptions {
            let arrPositive = option["positive"] as! [String]
            let arrNegative = option["negative"] as! [String]
            
            let arrPositiveValues = arrPositive.map{ return getNodeState(id: $0) }
            let arrNegativeValues = arrNegative.map{ return getNodeState(id: $0) }
            
            let isAllPositive = !arrPositiveValues.contains(false)
            let isAllNegative = !arrNegativeValues.contains(true)
            
            print("OPTIONS === \(option)")
            print("arrPositive === \(arrPositive)")
            print("negative === \(arrNegative)")
            
            print("arrPositiveValues === \(arrPositiveValues)")
            print("arrNegativeValues === \(arrNegativeValues)")
            
            print("isAllPOS === \(isAllPositive)")
            print("isAllNeg === \(isAllNegative)")
            
            if let exitType = option[GCGModesParser.exitType] as? String {
                removeValueForPPKey()
                saveState(key: exitType, value: modeValue.yes.rawValue)
            }
          
            if let checkContains = option["contains"] as? [String] {
                if isArrStateSavedFor(keys: checkContains) {
                    toPoint = option[GCGModesParser.toPoint] as? String
                    return toPoint
                }
            }
            
            if arrPositiveValues.count > 0 && arrNegativeValues.count > 0 {
                
                
                
                
                if isAllNegative && isAllPositive {
                    toPoint = option[GCGModesParser.toPoint] as? String
                }
                
                
            } else if arrNegative.count == 0 {
                
                
                if isAllPositive {
                    toPoint = option[GCGModesParser.toPoint] as? String
                }
                
                
            } else if arrPositive.count == 0 {
                
                if isAllNegative {
                    toPoint = option[GCGModesParser.toPoint] as? String
                }
                
            } else {
                
                toPoint = option[GCGModesParser.toPoint] as? String
            }
            
        }
        print("TOPPPP === \(toPoint)")
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
    
    //    mutating func moveToStepNext() {
    //        if let safeDicCurrentState = dicCurrentState[GCGModesParser.toPoint] as? String {
    //            dicCurrentState = dicMain[safeDicCurrentState]! as! [String : Any]
    //        } else if let __text = dicCurrentState[GCGModesParser.title] as? String, !__text.isEmpty  {
    //            if let nextStepText = dicCurrentState[GCGModesParser.toPoint] as? String,
    //                let toStep = dicMain[nextStepText] as? [String:Any] {
    //                dicCurrentState = toStep
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
    //
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
