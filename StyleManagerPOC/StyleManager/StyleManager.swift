//
//  StyleManager.swift
//  LendingStream
//
//  Created by Sankar Narayanan on 23/12/15.
//  Copyright © 2015 GlobalAnalytics. All rights reserved.
//

import Foundation
import UIKit

class StyleManager {
    
    enum styleFiles : String {
        case styleDetails = "StyleDetails"
    }
    
    enum containers : String{
        case generic = "GenericStyles"
        case sampleViewController = "SampleViewController"
    }
    
    var selectedStyleFile : styleFiles?
    var selctedDataSource : [String:AnyObject]?
    
    class var sharedInstance : StyleManager {
        struct Singleton {
            static let instance = StyleManager()
        }
        return Singleton.instance
    }
    
    func loadTheme(currentStyleFile : styleFiles){
        if (self.selctedDataSource == nil || self.selectedStyleFile != currentStyleFile){
            self.selectedStyleFile = currentStyleFile
            var currentTheme : [String:AnyObject]?
            if let themesJSON = NSBundle.mainBundle().pathForResource(currentStyleFile.rawValue, ofType: "json"){
                if let jsonData = NSData(contentsOfFile: themesJSON){
                    do{
                        currentTheme = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.AllowFragments) as? [String:AnyObject]
                    }catch _{
                        print("Unable to load JSON file")
                    }
                    
                }
            }
            self.selctedDataSource = currentTheme
        }
    }
    
    func applyGenericStyles(commonStyleContainer : containers){
        for elementDetail in self.getElementsInContainer(commonStyleContainer){
            if let elementName = elementDetail as? String{
                switch(elementName){
                case "Label":
                    UILabel.appearance().applyStyles(withStyleInfo: elementName, inContainer: commonStyleContainer)
                    break
                case "Button":
                    UIButton.appearance().applyStyles(withStyleInfo: elementName, inContainer: commonStyleContainer)
                    break
                default:
                    break
                }
            }
        }
    }
    
    func applyStylesForContainer(containerIdentifier : containers, currentViewController : UIViewController){
        for elementDetail in self.getElementsInContainer(containerIdentifier){
            if let elementName = elementDetail as? String{
                let styleDict = StyleManager.sharedInstance.getSpecificStyle(containerIdentifier, forElement: elementName)
                if let tagIdentifier = styleDict["iOS-tag"]{
                    if let currentUiElement = currentViewController.view.viewWithTag(tagIdentifier as? Int ?? 0){
                        if(currentUiElement.isKindOfClass(UILabel.self)){
                            let label : UILabel = currentUiElement as! UILabel
                            label.applyStyles(withStyleInfo: elementName, inContainer: containerIdentifier)
                        }else if(currentUiElement.isKindOfClass(UIButton.self)){
                            let label : UIButton = currentUiElement as! UIButton
                            label.applyStyles(withStyleInfo: elementName, inContainer: containerIdentifier)
                        }
                    }
                }
            }
        }
    }
    
    func applyCustomStyleForElement(elementName: String, containerIdentifier : containers){
        
    }
    
    func getThemeDetails(withTheme: styleFiles) -> [String:AnyObject]
    {
        self.selectedStyleFile = withTheme
        var currentTheme : [String:AnyObject]?
        if let themesJSON = NSBundle.mainBundle().pathForResource(withTheme.rawValue, ofType: "json"){
            if let jsonData = NSData(contentsOfFile: themesJSON){
                do{
                    currentTheme = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.AllowFragments) as? [String:AnyObject]
                }catch _{
                    print("Unable to load theme JSON file")
                }
                
            }
        }
        self.selctedDataSource = currentTheme
        return currentTheme!
    }
    
    
    func getElementsInContainer(containerName: containers) -> Array<AnyObject>{
        if let currentContainer = self.selctedDataSource?[containerName.rawValue]{
            return currentContainer.allKeys
        }else{
            return []
        }
    }
    
    func getSpecificStyle(inContainer: containers, forElement: String) -> [String:AnyObject]
    {
        if let currentContainer = self.selctedDataSource?[inContainer.rawValue]{
            if let currentStyleNode = currentContainer[forElement] as? [String:AnyObject]{
                return currentStyleNode
            }
        }else{
            self.selctedDataSource = self.getThemeDetails(styleFiles.styleDetails)
            if let currentContainer = self.selctedDataSource?[inContainer.rawValue]{
                if let currentStyleNode = currentContainer[forElement] as? [String:AnyObject]{
                    return currentStyleNode
                }
            }
            return ["":""]
        }
        return ["":""]
    }
    
}

extension UILabel{
    func applyStyles(withStyleInfo styleInfo: String, inContainer : StyleManager.containers) {
        let styleDict = StyleManager.sharedInstance.getSpecificStyle(inContainer, forElement: styleInfo)
        if let font = styleDict["font-family"], size = styleDict["font-size"]{
            self.font = UIFont(name: font as! String, size: CGFloat(NSNumberFormatter().numberFromString(size as! String)!))
        }
        if let fColor = styleDict["font-color"]{
            self.textColor = UIColor.colorWithHexValue(fColor as! String)
        }
        if let bColor = styleDict["background-color"]{
            self.backgroundColor = UIColor.colorWithHexValue(bColor as! String)
        }
        if let borderRadius = styleDict["border-radius"]{
            self.layer.cornerRadius = borderRadius as! CGFloat
        }
    }
}

extension UIButton {
    func applyStyles(withStyleInfo styleInfo: String, inContainer : StyleManager.containers) {
        let styleDict = StyleManager.sharedInstance.getSpecificStyle(inContainer, forElement: styleInfo)
        if let color = styleDict["font-color"]{
            self.setTitleColor(UIColor.colorWithHexValue(color as! String), forState: UIControlState.Normal)
            self.setTitleColor(UIColor.colorWithHexValue(color as! String), forState: UIControlState.Highlighted)
            self.setTitleColor(UIColor.colorWithHexValue(color as! String), forState: UIControlState.Selected)
        }
        
        if let font = styleDict["font-family"], size = styleDict["font-size"]{
            self.titleLabel?.font = UIFont(name: font as! String, size: CGFloat(NSNumberFormatter().numberFromString(size as! String)!))
        }
        if let borderColor = styleDict["border-color"]{
            self.layer.borderColor =  UIColor.colorWithHexValue(borderColor as! String).CGColor
        }
        if let borderRadius = styleDict["border-radius"]{
            self.layer.cornerRadius = borderRadius as! CGFloat
        }
    }
    
}

extension UIColor {
    @objc class func colorWithHexValue(hexValue:NSString) -> UIColor {
        var c:UInt32 = 0xffffff
        if hexValue.hasPrefix("#") {
            NSScanner(string: hexValue.substringFromIndex(1)).scanHexInt(&c)
        }else{
            NSScanner(string: hexValue as String).scanHexInt(&c)
        }
        if hexValue.length > 7 {
            return UIColor(red: CGFloat((c & 0xff000000) >> 24)/255.0, green: CGFloat((c & 0xff0000) >> 16)/255.0, blue: CGFloat((c & 0xff00) >> 8)/255.0, alpha: CGFloat(c & 0xff)/255.0)
        }else{
            return UIColor(red: CGFloat((c & 0xff0000) >> 16)/255.0, green: CGFloat((c & 0xff00) >> 8)/255.0, blue: CGFloat(c & 0xff)/255.0, alpha: 1.0)
        }
    }
}


