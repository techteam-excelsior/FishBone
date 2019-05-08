//
//  HomeViewController.swift
//  Main
//
//  Created by Gaurav Pai on 17/03/19.
//  Copyright © 2019 Gaurav Pai. All rights reserved.
//

import UIKit

var data = helperDatabase()

class HomeViewController: UIViewController, UIDropInteractionDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate, AppFileManipulation, AppFileStatusChecking, AppFileSystemMetaData, UITextViewDelegate, UIPageViewControllerDelegate, UITextFieldDelegate {
    
    
    // MARK: - Properties
    
    static var delegate: HomeControllerDelegate?
    var primaryBoneCount = 0
    var primaryBoneArray = [BoneShape]()
    var tapGesture : UITapGestureRecognizer!
    var scrollView: UIScrollView!
    var mainView: UIView!
    var activeTextView: UITextView?
    var activeTextField: UITextField?
    var lastOffset: CGPoint!
    var keyboardHeight: CGFloat = 0
    var jsonData : Data?
    var oldjSONData : Data?
    var allData = entireBoneData()
    
    private var primaryBoneIndex: Int!
    private var secondaryBoneIndex: Int!
    private var didClickPrimaryBone = false
    private var didClickSecondaryBone = false
    private let height = UIScreen.main.bounds.height
    private let width = UIScreen.main.bounds.width
    private var mainBoneLayer = CAShapeLayer()
    private var insertBone : UIButton  = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 150, height: 40)
        button.setImage(#imageLiteral(resourceName: "createNew"), for: .normal)
        button.backgroundColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var problemStatement : UITextView = {
        let view = UITextView()
        view.layer.shadowRadius = 3
        view.layer.shadowColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        view.layer.borderWidth = 1
        view.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        view.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        view.font = UIFont(name: "Zapfino", size: 34)
        view.frame = CGRect(x:0 , y:0 , width: 250, height: 80)
        view.isScrollEnabled = false
        view.textAlignment = .center
        return view
    }()
    
    
    
    // MARK: - Integration Properties
    
    //variables that falicitate drawing arrows between two pluses(circle view with plus image inside)
    static var uniqueProcessID = 0
    var showTemplate = 0
    
    override func viewDidLoad()
    {
        
        super.viewDidLoad()
        configureNavigationBar()
        configureScrollView()
        addInsertButton()
        addMainBoneLayer()
        addProblemStatement()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        ContainerViewController.menuDelegate = self
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap(tapGesture:)))
        tapGesture.numberOfTapsRequired = 2
        tapGesture.delegate = self
        self.mainView.addGestureRecognizer(tapGesture)
        
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(didSingleTap(_:)))
        singleTapGesture.numberOfTapsRequired = 1
        singleTapGesture.delegate = self
        self.mainView.addGestureRecognizer(singleTapGesture)
        singleTapGesture.require(toFail: tapGesture)
        
        for i in 0...5 {
            if i%2 == 0
            {
                let frame = CGRect(x: mainBoneLayer.frame.maxX - CGFloat((i+1)*275), y: self.mainBoneLayer.frame.minY - 600, width: 80, height: 600 )
                let bone = BoneShape(withFrame: frame, boneIndex: i, isPrimaryBone: true, boneFrame: CGRect(x: 0, y: 0, width: 0, height: 0))
                bone.path = UIBezierPath.arrow(from: CGPoint(x: bone.bounds.maxX, y: bone.bounds.height-10), to: CGPoint(x: bone.bounds.minX, y: bone.bounds.minY), tailWidth: 2, headWidth: 10, headLength: 18).cgPath
                self.mainView.layer.addSublayer(bone)
                self.mainView.addSubview(bone.boneTextField)
                bone.lineWidth = 1.0
                bone.strokeColor = UIColor.black.cgColor
                bone.fillColor = UIColor.black.cgColor
                bone.isHidden = true
                bone.boneTextField.isHidden = true
                primaryBoneArray.append(bone)
            }
                
            else
            {
                let frame = CGRect(x: mainBoneLayer.frame.maxX - CGFloat(i * 275), y: mainBoneLayer.frame.maxY, width: 80, height: 600)
                let bone = BoneShape(withFrame: frame, boneIndex: i, isPrimaryBone: true, boneFrame: CGRect(x: 0, y: 0, width: 0, height: 0))
                bone.path = UIBezierPath.arrow(from:CGPoint(x: bone.bounds.maxX, y: bone.bounds.minY + 10) , to: CGPoint(x: bone.bounds.minX, y: bone.bounds.height), tailWidth: 2, headWidth: 10, headLength: 18).cgPath
                self.mainView.layer.addSublayer(bone)
                self.mainView.addSubview(bone.boneTextField)
                bone.lineWidth = 1.0
                bone.strokeColor = UIColor.black.cgColor
                bone.fillColor = UIColor.black.cgColor
                bone.isHidden = true
                bone.boneTextField.isHidden = true
                primaryBoneArray.append(bone)
            }
        }
        // End of funciton viewDidLoad()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func addMainBoneLayer() {
        self.mainView.layer.addSublayer(mainBoneLayer)
        mainBoneLayer.frame = CGRect(x: mainView.bounds.minX, y: self.mainView.bounds.height/2 - 25, width: self.mainView.bounds.maxX - 350 , height: 50)
        mainBoneLayer.path = UIBezierPath.arrow(from: CGPoint(x: 180, y: mainBoneLayer.bounds.height/2), to: CGPoint(x: mainBoneLayer.bounds.width-20, y: mainBoneLayer.bounds.height/2), tailWidth: 4, headWidth: 15, headLength: 22).cgPath
        mainBoneLayer.lineWidth = 3.0
        mainBoneLayer.strokeColor = UIColor.black.cgColor
        mainBoneLayer.fillColor = UIColor.black.cgColor
    }
    
    func addProblemStatement(){
        problemStatement.center = CGPoint(x: mainBoneLayer.frame.maxX + 145, y: mainBoneLayer.frame.midY)
        problemStatement.delegate = self
        self.mainView.addSubview(problemStatement)
    }
    
    
    func addInsertButton(){
        self.view.addSubview(insertBone)
        insertBone.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20).isActive = true
        insertBone.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -20).isActive = true
        insertBone.widthAnchor.constraint(equalToConstant: 50).isActive = true
        insertBone.heightAnchor.constraint(equalToConstant: 50).isActive = true
        insertBone.addTarget(self, action: #selector(insertSubBones), for: .touchUpInside)
    }
    
    
    @objc func didSingleTap(_ sender: UITapGestureRecognizer) {
        for primaryBone in primaryBoneArray{
            primaryBone.strokeColor = UIColor.black.cgColor
            primaryBone.fillColor = UIColor.black.cgColor
            didClickPrimaryBone = false
            primaryBoneIndex = nil
            
            for secondaryBone in primaryBone.secondaryBoneArray {
                secondaryBone.strokeColor = UIColor.black.cgColor
                secondaryBone.fillColor = UIColor.black.cgColor
                didClickSecondaryBone = false
                secondaryBoneIndex = nil
            }
        }
        
        if activeTextField != nil {
            activeTextField?.resignFirstResponder()
        }
        
        if activeTextView != nil {
            activeTextView?.resignFirstResponder()
        }
    }
    
    
    @objc func didDoubleTap(tapGesture: UITapGestureRecognizer)
    {
        for primaryBone in primaryBoneArray{
            primaryBone.strokeColor = UIColor.black.cgColor
            primaryBone.fillColor = UIColor.black.cgColor
            didClickPrimaryBone = false
            primaryBoneIndex = nil
            
            for secondaryBone in primaryBone.secondaryBoneArray {
                secondaryBone.strokeColor = UIColor.black.cgColor
                secondaryBone.fillColor = UIColor.black.cgColor
                didClickSecondaryBone = false
                secondaryBoneIndex = nil
            }
        }
        
        let tapPoint = tapGesture.location(in: self.mainView)
        print(tapPoint)
        for primaryIndex in 0..<primaryBoneCount
        {
            if primaryBoneArray[primaryIndex].frame.contains(tapPoint)
            {
                primaryBoneArray[primaryIndex].strokeColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1).cgColor
                primaryBoneArray[primaryIndex].fillColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1).cgColor
//                bonesArray[index].backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1).cgColor
                print("Clicked Primary Bone Number:",primaryIndex)
                didClickPrimaryBone = true
                primaryBoneIndex = primaryIndex
                secondaryBoneIndex = nil
                break
            }
            
            for secondaryIndex in 0..<primaryBoneArray[primaryIndex].secondaryBoneCount
            {
                if primaryBoneArray[primaryIndex].secondaryBoneArray[secondaryIndex].frame.contains(tapPoint)
                {
                    primaryBoneArray[primaryIndex].secondaryBoneArray[secondaryIndex].strokeColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1).cgColor
                    primaryBoneArray[primaryIndex].secondaryBoneArray[secondaryIndex].fillColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1).cgColor
//                    bonesArray[index].backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1).cgColor
                    print("Clicked Secondary Bone Number:",primaryIndex,secondaryIndex)
                    didClickSecondaryBone = true
                    primaryBoneIndex = primaryIndex
                    secondaryBoneIndex = secondaryIndex
                }
                
            }
        }
        if mainBoneLayer.frame.contains(tapPoint)
        {
            print("Clicked the arrow")
//            mainBoneLayer.backgroundColor = #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1).cgColor
        }
    }
    
    @objc func insertSubBones() {
        
        if didClickPrimaryBone
        {
            let primaryBone = primaryBoneArray[primaryBoneIndex]
            if primaryBone.secondaryBoneCount < 3
            {
//                print("Showing Secondary Bone Number",primaryBoneIndex,",",primaryBone.secondaryBoneCount)
                self.mainView.layer.addSublayer(primaryBone.secondaryBoneArray[primaryBone.secondaryBoneCount])
                self.mainView.addSubview(primaryBone.secondaryBoneArray[primaryBone.secondaryBoneCount].boneTextField)
                primaryBone.secondaryBoneArray[primaryBone.secondaryBoneCount].boneTextField.delegate = self
                primaryBone.secondaryBoneCount+=1
//                didClickPrimaryBone = false
            }
            else {
                showToast(message: "Only 3 Bones Allowed")
                didClickPrimaryBone = false
            }
        }
        else if didClickSecondaryBone {
            
//            print("Showing Why Bone For Secondary Bone Number",primaryBoneIndex,",",secondaryBoneIndex)
            let secondaryBone = primaryBoneArray[primaryBoneIndex].secondaryBoneArray[secondaryBoneIndex]
            if secondaryBone.secondaryBoneCount < 1{
                print("Print 2",secondaryBone.whyBone.frame)
                self.mainView.layer.addSublayer(secondaryBone.whyBone)
                secondaryBone.doesHaveWhyAnalysis = true
                secondaryBone.secondaryBoneCount+=1
                self.mainView.addSubview(secondaryBone.whyText)
                secondaryBone.whyText.delegate = self
//                didClickSecondaryBone = false
            }
            else{
                showToast(message: "Only 1 root cause analysis allowed")
                didClickSecondaryBone = false
            }
        }
        else
        {
            if primaryBoneCount<6
            {
//                print("Showing Primary Bone Number:",primaryBoneCount)
                primaryBoneArray[primaryBoneCount].isHidden = false
                primaryBoneArray[primaryBoneCount].boneTextField.isHidden = false
                primaryBoneArray[primaryBoneCount].boneTextField.delegate = self
                primaryBoneCount+=1
            }
            else
            {
                self.showToast(message: "Only 6 Bones allowed")
            }
            
        }
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        print("Called")
        let fixedWidth = CGFloat(250)
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textView.frame = newFrame
        textView.center = CGPoint(x: mainBoneLayer.frame.maxX + 145, y: mainBoneLayer.frame.midY)

        
        let distanceToBottom = self.scrollView.frame.size.height - (activeTextView?.frame.origin.y)!/2 - (activeTextView?.frame.size.height)!/2
        let collapseSpace = keyboardHeight - distanceToBottom
        if collapseSpace > 0 {
            // set new offset for scroll view
            UIView.animate(withDuration: 0.3, animations: {
                // scroll to the position above keyboard 10 points
                self.scrollView.contentOffset = CGPoint(x: self.lastOffset.x, y: collapseSpace + 10)
            })
        }
        print("In text view: ",self.mainView.frame)
        //Update the scrollView content size to account for the increased contentView
        let size = self.mainView.frame.size
        self.scrollView.contentSize = CGSize(width: size.width, height: size.height + keyboardHeight)
        self.mainView.layoutIfNeeded()
    }
    
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        print("Entered")
//        let distanceToBottom = self.scrollView.frame.size.height - (textField.frame.origin.y) - (textField.frame.size.height)
//        let collapseSpace = keyboardHeight - distanceToBottom
//        if collapseSpace > 0 {
//            // set new offset for scroll view
//            UIView.animate(withDuration: 0.3, animations: {
//                // scroll to the position above keyboard 10 points
//                self.scrollView.contentOffset = CGPoint(x: self.lastOffset.x, y: collapseSpace)
//            })
//        }
//        //Update the scrollView content size to account for the increased contentView
//        let size = self.mainView.frame.size
//        self.scrollView.contentSize = CGSize(width: size.width, height: size.height)
//        self.mainView.layoutIfNeeded()
//    }
    // MARK: - Handlers
    
    func configureScrollView(){
        self.scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        self.view.addSubview(scrollView!)
        self.scrollView!.backgroundColor = #colorLiteral(red: 1, green: 0.9561161762, blue: 0.8509541534, alpha: 1)
        let deltaX = 64 * self.view.frame.width / self.view.frame.height
        self.scrollView?.delegate = self
        self.mainView = UIView(frame: CGRect(x: 0, y: 0, width: (self.view.frame.width + deltaX) * 2 , height: self.view.frame.height * 2))
        self.scrollView!.contentSize = CGSize(width: (self.mainView.frame.width), height: (self.mainView.frame.height))
        self.scrollView!.addSubview(mainView!)
//        let newContentOffsetX = (scrollView.contentSize.width - scrollView.frame.size.width) / 2
//        scrollView.contentOffset = CGPoint(x: newContentOffsetX,y: 0)
        self.mainView!.backgroundColor = #colorLiteral(red: 1, green: 0.9561161762, blue: 0.8509541534, alpha: 1)
        self.scrollView?.canCancelContentTouches = false
        //set appropriate zoom scale for the scroll view
        let zoomScale = self.view.frame.width / ((self.view.frame.width + deltaX) * 2)
        self.scrollView!.maximumZoomScale = 1.5
        self.scrollView!.minimumZoomScale = zoomScale
        self.scrollView!.setZoomScale(zoomScale, animated: true)
        self.scrollView?.showsVerticalScrollIndicator = false
        self.scrollView?.showsHorizontalScrollIndicator = false
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.mainView!
    }

    func configureNavigationBar()
    {
        
        navigationController?.navigationBar.barTintColor = UIColor.darkGray
        navigationController?.navigationBar.barStyle = .blackTranslucent
        navigationItem.title = "Excelsior"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "options")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(didClickMenu))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "exit")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(didClickExit))
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if keyboardHeight != 0 {
            print("keyboard height 0")
            return
        }
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
            //Increase the scrollView contentsize so it is scrollable beyond the keyboard
            var distanceToBottom : CGFloat = 0
            let size = self.scrollView.contentSize
            self.scrollView.contentSize = CGSize(width: size.width, height: size.height + keyboardHeight)
            // move if keyboard hide input field
            if activeTextView != nil {
                distanceToBottom = self.scrollView.frame.size.height - (activeTextView?.frame.origin.y ?? 0)/2 - (activeTextView?.frame.size.height ?? 0)/2
                print(distanceToBottom)
            }
            if activeTextField != nil {
                distanceToBottom = self.scrollView.frame.size.height - (activeTextField?.frame.origin.y ?? 0)/2 - (activeTextField?.frame.size.height ?? 0)/2
                print(distanceToBottom)
            }
            let collapseSpace = keyboardHeight - distanceToBottom + 50
            if collapseSpace < 0 {
                return
            }
            // set new offset for scroll view
            UIView.animate(withDuration: 0.3, animations: {
                // scroll to the position above keyboard 10 points
                self.scrollView.contentOffset = CGPoint(x: self.lastOffset.x, y: collapseSpace + 10)
            })
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.lastOffset == nil {
            return
        }
        UIView.animate(withDuration: 0.1) {
            self.scrollView.contentOffset = self.lastOffset
        }
        let size = self.mainView.frame.size
        self.scrollView.contentSize = CGSize(width: size.width, height: size.height)
        keyboardHeight = 0
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        activeTextView = textView
        lastOffset = self.scrollView.contentOffset
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeTextField = textField
        activeTextView = nil
        lastOffset = self.scrollView.contentOffset
        return true
    }
    
    private func textViewShouldReturn(_ textView: UITextView) -> Bool {
        activeTextView?.resignFirstResponder()
        activeTextView = nil
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        activeTextField?.resignFirstResponder()
        activeTextField = nil
        return true
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.layer.borderWidth = 0
        textView.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        textView.backgroundColor = #colorLiteral(red: 1, green: 0.9561161762, blue: 0.8509541534, alpha: 1)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        textField.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        textField.layer.borderWidth = 0
        textField.backgroundColor = #colorLiteral(red: 1, green: 0.9561161762, blue: 0.8509541534, alpha: 1)
    }
    
    
    
    func checkForChanges()
    {
        
    }
    
    func load_action()
    {
//        let fileName = LandingPageViewController.projectName+".excelsior"
//        let file = FileHandling(name: fileName)
//        if file.findFile(in: .ProjectInShared) {
//            try? self.jsonData = Data(contentsOf: getURL(for: .ProjectInShared).appendingPathComponent(fileName), options: .uncachedRead)
//            print("Data encoded")
//            let jsonDecoder = JSONDecoder()
//            let decodedData = try? jsonDecoder.decode(entireBoneData.self, from: self.jsonData!)
//            if decodedData != nil {
//                let allData = decodedData
//                restoreState(allData: allData!)
//            }
//        }
    }
    
    func restoreState(allData: entireBoneData){
        for i in 0..<allData.bones.count{
            let presentPrimaryBone = allData.bones[i]
            insertSubBones()
            primaryBoneArray[i].boneTextField.text = presentPrimaryBone.boneText
            for j in 0..<presentPrimaryBone.subBoneArray.count{
                let presentSecondaryBone = presentPrimaryBone.subBoneArray[j]
                didClickPrimaryBone = true
                insertSubBones()
                primaryBoneArray[i].secondaryBoneArray[j].boneTextField.text = presentSecondaryBone.boneText
                didClickPrimaryBone = false
                if presentSecondaryBone.isWhyEnabled{
                    didClickSecondaryBone = true
                    insertSubBones()
                    primaryBoneArray[i].secondaryBoneArray[j].whyText.text = presentSecondaryBone.whyText
                }
            }
            
        }
        didClickPrimaryBone = false
        
        
        
    }
    
    //    Generates unique ID for the shapes
    func getUniqueID() -> Int{
        HomeViewController.uniqueProcessID += 1
        return HomeViewController.uniqueProcessID
    }
    
    @objc func didClickExit(){
        
        checkForChanges()
        dismiss(animated: true, completion: nil)
    }
    
    
    @objc func didClickMenu()
    {
        HomeViewController.delegate?.handleMenuToggle(forMenuOption: nil)
    }

    // End of Class HomeViewController
}


// Extenstions

extension UIImage {
    func isEqual(to image: UIImage) -> Bool {
        guard let data1: Data = self.pngData(),
            let data2: Data = image.pngData() else {
                return false
        }
        return data1.elementsEqual(data2)
    }
}

extension FloatingPoint {
    func rounded(to value: Self, roundingRule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> Self{
        return (self / value).rounded(roundingRule) * value
        
    }
}

extension CGPoint {
    func rounded(to value: CGFloat, roundingRule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> CGPoint{
        return CGPoint(x: CGFloat((self.x / value).rounded(.toNearestOrAwayFromZero) * value), y: CGFloat((self.y / value).rounded(.toNearestOrAwayFromZero) * value))
    }
}

extension CGRect {
    func rounded(to value: CGFloat, roundingRule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> CGRect{
        return CGRect(x: self.origin.x, y: self.origin.y, width: CGFloat((self.width / value).rounded(.toNearestOrAwayFromZero) * value), height: CGFloat((self.height / value).rounded(.toNearestOrAwayFromZero) * value))
    }
}

extension UIViewController {
    
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x:0, y: 0, width: 150, height: 40))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = "  "+message+"  "
        toastLabel.sizeToFit()
        toastLabel.center = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height-75)
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 5;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    } }

extension UIViewController {
    func showInputDialog(title:String? = nil,
                         subtitle:String? = nil,
                         actionTitle:String? = "Add",
                         cancelTitle:String? = "Cancel",
                         inputPlaceholder:String? = nil,
                         inputKeyboardType:UIKeyboardType = UIKeyboardType.default,
                         cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil,
                         actionHandler: ((_ text: String?) -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        alert.addTextField { (textField:UITextField) in
            textField.placeholder = inputPlaceholder
            textField.keyboardType = inputKeyboardType
        }
        alert.addAction(UIAlertAction(title: actionTitle, style: .destructive, handler: { (action:UIAlertAction) in
            guard let textField =  alert.textFields?.first else {
                actionHandler?(nil)
                return
            }
            actionHandler?(textField.text)
        }))
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelHandler))
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension HomeViewController: menuControllerDelegate
{
    func moveToTrash() {
        
    }
    
    func listTrashItems() {
        
    }
    
    func saveIntoVariables()
    {
        let jsonEncoder = JSONEncoder()
        allData.primaryBoneCount = primaryBoneCount
        for i in 0..<primaryBoneCount{
            var primaryBoneData = boneData()
            let presentBone = primaryBoneArray[i]
            primaryBoneData.boneText = presentBone.boneTextField.text!
            primaryBoneData.subBoneCount = presentBone.secondaryBoneCount
            for j in 0..<presentBone.secondaryBoneCount{
                var secondaryBoneData = boneData()
                let presentSecondaryBone = presentBone.secondaryBoneArray[j]
                secondaryBoneData.boneText = presentSecondaryBone.boneTextField.text!
                secondaryBoneData.isWhyEnabled = presentSecondaryBone.doesHaveWhyAnalysis
                secondaryBoneData.whyText = presentSecondaryBone.whyText.text!
                primaryBoneData.subBoneArray.append(secondaryBoneData)
            }
            allData.bones.append(primaryBoneData)
        }
        self.jsonData = try? jsonEncoder.encode(allData)
        print(String(describing: self.jsonData))
    }
    
    func saveViewState() {
        
        saveIntoVariables()
        
        //        let path = getURL(for: .Documents).appendingPathComponent(LandingPageViewController.projectName)
        let fileName = LandingPageViewController.projectName+".excelsior"
        if writeFile(containing: String(data: jsonData!, encoding: .utf8)!, to: getURL(for: .ProjectInShared), withName: fileName) {
            self.showToast(message: "Saved Successfully.")
        }
        print(getURL(for: .Shared))
    }
    
    func saveViewStateAsNew() {
        
        let alert = UIAlertController(title: "Enter the name of the Project", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "The name should be unique"
        })
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            if ((alert.textFields?.first?.text) != nil)
            {
                LandingPageViewController.projectName = alert.textFields!.first!.text!
                let directory = FileHandling(name: LandingPageViewController.projectName)
                if directory.createSharedProjectDirectory(), directory.createDocumentsProjectDirectory()
                {
                    print("Directory successfully created!")
                    //                    let path = self.getURL(for: .Documents).appendingPathComponent(LandingPageViewController.projectName)
                    self.saveIntoVariables()
                    let fileName = LandingPageViewController.projectName+".excelsior"
                    if self.writeFile(containing: String(data: self.jsonData!, encoding: .utf8)!, to: self.getURL(for: .ProjectInShared), withName: fileName)
                    {
                        self.showToast(message: "Saved Successfully")
                    }
                }
            }
        }))
        self.present(alert, animated: true)
    }
    
    func takeScreenShot()
    {
        self.showToast(message: "Screenshot captured!")
        
    }
    
    func exportAsPDF()
    {
        self.showToast(message: "PDF created successfully")
        
    }
}


extension HomeViewController: homeDelegate {
    func addSubView(textField: UITextField) {
        self.view.addSubview(textField)
    }
    
    
}

extension String {
    func encodeUrl() -> String? {
        return self.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
    }
    func decodeUrl() -> String? {
        return self.removingPercentEncoding
    }
}

extension UITextView {
    @IBInspectable var doneAccessory: Bool{
        get{
            return self.doneAccessory
        }
        set (hasDone){
            if hasDone{
                addDoneButtonOnKeyboard()
            }
        }
    }
    
    func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done:UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        let items = [flexSpace,done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        self.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction(){
        self.resignFirstResponder()
    }
}
