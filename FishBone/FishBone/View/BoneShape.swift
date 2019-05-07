//
//  BoneShape.swift
//  FishBone
//
//  Created by Gaurav Pai on 01/05/19.
//  Copyright © 2019 excelsiortechteam. All rights reserved.
//

import UIKit

class BoneShape: CAShapeLayer, UITextFieldDelegate {

    var secondaryBoneCount : Int!
    var maxSecondaryBoneCount: Int!
    var doesHaveWhyAnalysis: Bool!
    var secondaryBoneArray : [BoneShape]!
    var boneIndex: Int!
    var boneTextField: UITextField!
    var boneText: String!
    var isPrimaryBone: Bool!
    var whyBone: CAShapeLayer!
    var boneFrame: CGRect!

    
    override init() {
        super.init()
        self.secondaryBoneCount = 0
        self.doesHaveWhyAnalysis = false
        self.secondaryBoneArray = []
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        guard layer is BoneShape else { return }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(withFrame frame: CGRect, boneIndex index: Int, isPrimaryBone: Bool, boneFrame: CGRect) {
        self.init()
        self.frame = frame
        self.boneIndex = index
        self.isPrimaryBone = isPrimaryBone
        self.boneFrame = boneFrame
        
        if isPrimaryBone {
            self.maxSecondaryBoneCount = 3
            boneTextField = UITextField()
            boneTextField.layer.borderWidth = 2.5
            boneTextField.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            boneTextField.backgroundColor = .white
            boneTextField.font = UIFont(name: "Avenir", size: 36)
            boneTextField.frame = CGRect(x:0 , y:0 , width: 180, height: 50)
            if boneIndex%2 == 0 {
                boneTextField.center = CGPoint(x: self.frame.minX, y: self.frame.minY-35)
            }
            else{
                boneTextField.center = CGPoint(x: self.frame.minX, y: self.frame.maxY+35)
            }
            for i in 0..<maxSecondaryBoneCount{
                insertSecondaryBone(withIndex: i, parentIndex: self.boneIndex)
            }
        }
        else{
            self.maxSecondaryBoneCount = 1
            boneTextField = UITextField()
            boneTextField.layer.borderWidth = 2.5
            boneTextField.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            boneTextField.backgroundColor = .white
            boneTextField.font = UIFont(name: "Avenir", size: 24)
            boneTextField.frame = CGRect(x:0 , y:0 , width: 180, height: 50)
            boneTextField.center = CGPoint(x: self.boneFrame.midX, y: self.boneFrame.midY-45)
            for _ in 0..<maxSecondaryBoneCount{
                insert5whyBone()
            }
        }
    }
    
    func insertSecondaryBone(withIndex index: Int, parentIndex: Int)
    {
                if parentIndex%2==0
                {
                    let frameX = self.frame.minX
                    let frameY = self.frame.minY
                    let frame = CGRect(x: frameX-300 + CGFloat((index)*20), y: frameY+CGFloat((index+1)*160), width: 300, height: 20)
                    let dummyFrame = CGRect(x: self.frame.minX-200 + CGFloat((index)*20), y: self.frame.minY+CGFloat((index+1)*160), width: 200, height: 20)
                    let secondaryBone = BoneShape(withFrame: frame, boneIndex: index, isPrimaryBone: false, boneFrame: dummyFrame )
                    secondaryBone.path = UIBezierPath.arrow(from:CGPoint(x: secondaryBone.bounds.minX, y: secondaryBone.bounds.maxY/2) , to: CGPoint(x: secondaryBone.bounds.maxX, y: secondaryBone.bounds.maxY/2), tailWidth: 2, headWidth: 10, headLength: 18).cgPath
                    secondaryBone.strokeColor = UIColor.black.cgColor
                    secondaryBone.fillColor = UIColor.black.cgColor
                    secondaryBone.shadowColor = UIColor.lightGray.cgColor
                    secondaryBoneArray.append(secondaryBone)
                }
        
                else if parentIndex%2 != 0
                {
                    let frameX = self.frame.minX
                    let frameY = self.frame.maxY
                    let frame = CGRect(x: frameX-300 + CGFloat((index)*20), y: frameY-CGFloat((index+1)*160), width: 300, height: 20)
                    let dummyFrame = CGRect(x: self.frame.minX-200 + CGFloat((index)*20), y: self.frame.maxY-CGFloat((index+1)*160), width: 200, height: 20)
                    let secondaryBone = BoneShape(withFrame: frame, boneIndex: index, isPrimaryBone: false, boneFrame: dummyFrame )
                    secondaryBone.path = UIBezierPath.arrow(from:CGPoint(x: secondaryBone.bounds.minX, y: secondaryBone.bounds.maxY/2) , to: CGPoint(x: secondaryBone.bounds.maxX, y: secondaryBone.bounds.maxY/2), tailWidth: 2, headWidth: 10, headLength: 18).cgPath
                    secondaryBone.strokeColor = UIColor.black.cgColor
                    secondaryBone.fillColor = UIColor.black.cgColor
                    secondaryBone.shadowColor = UIColor.lightGray.cgColor
                    secondaryBoneArray.append(secondaryBone)
                }
                
    //End of func insertSubBone
    }
    
    func insert5whyBone()
    {
        whyBone = CAShapeLayer()
        whyBone.frame = CGRect(x: self.frame.minX+40, y: self.frame.midY, width: 40, height: 100)
        whyBone.path = UIBezierPath.arrow(from:CGPoint(x: whyBone.bounds.minX, y: whyBone.bounds.maxY) , to: CGPoint(x: whyBone.bounds.maxX, y: whyBone.bounds.minY), tailWidth: 2, headWidth: 10, headLength: 18).cgPath
        whyBone.strokeColor = UIColor.black.cgColor
        whyBone.fillColor = UIColor.black.cgColor
        whyBone.shadowColor = UIColor.lightGray.cgColor
//        whyBone.backgroundColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        boneText = textField.text
    }
    

    
    
    
// End of Class BoneShape
}
