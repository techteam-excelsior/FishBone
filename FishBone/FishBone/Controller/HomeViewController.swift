//
//  HomeViewController.swift
//  Main
//
//  Created by Gaurav Pai on 17/03/19.
//  Copyright © 2019 Gaurav Pai. All rights reserved.
//

import UIKit

var data = helperDatabase()

class HomeViewController: UIViewController, UIDropInteractionDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate, AppFileManipulation, AppFileStatusChecking, AppFileSystemMetaData {
    
    
    // MARK: - Properties
    
    static var delegate: HomeControllerDelegate?
    
    //slider variables
    private let height = UIScreen.main.bounds.height
    private let width = UIScreen.main.bounds.width
    
    
    // MARK: - Integration Properties
    
    //variables that falicitate drawing arrows between two pluses(circle view with plus image inside)
    var jsonData : Data?
    var oldjSONData : Data?
    static var uniqueProcessID = 0
    var showTemplate = 0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        configureNavigationBar()
        ContainerViewController.menuDelegate = self
        self.view.backgroundColor = .white
    }

    
    // MARK: - Handlers
    
    // To add the left bar button to bring up the Menu
    func configureNavigationBar()
    {
        
        navigationController?.navigationBar.barTintColor = UIColor.darkGray
        navigationController?.navigationBar.barStyle = .blackTranslucent
        navigationItem.title = "Excelsior"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "options")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(didClickMenu))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "exit")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(didClickExit))
    }
    
    
    func checkForChanges()
    {
        
    }
    
    func load_action()
    {
        
    }
    
    func restoreState(allData: entireData)
    {
        
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




extension String {
    func encodeUrl() -> String? {
        return self.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
    }
    func decodeUrl() -> String? {
        return self.removingPercentEncoding
    }
}
