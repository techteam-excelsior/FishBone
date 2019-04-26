//
//  LandingPage.swift
//  diagram_iOS
//
//  Created by Gaurav Pai on 03/04/19.
//  Copyright © 2019 Gaurav Pai. All rights reserved.
//

import Foundation
import UIKit

enum AppDirectories: String {
    case Documents = "Documents"
    case Inbox = "Inbox"
    case Library = "Library"
    case Temp = "tmp"
    case Project = "Project"
    case Shared = "Shared"
    case ApplicationInShared = "ApplicationInShared"
    case ProjectInShared = "ProjectInShared"
}


struct FileHandling : AppFileManipulation, AppFileStatusChecking, AppFileSystemMetaData
{

    let name: String
    
    init(name: String) {
        self.name = name
    }
    
    func createSharedProjectDirectory() -> Bool{
        if createSharedDirectory(withName: name)
        {
            return true
        }
        print("Did not create Shared Directory because it already exists")
        return false
    }
    
    func createDocumentsProjectDirectory() -> Bool
    {
        if createDocumentsDirectory(withName: name)
        {
            print("Created Project Directory in Documents")
            return true
        }
        print("Did not create Project Directory in Documents as it already exists")
        return false
    }
    
    func listProjects() -> [String]
    {
        return list(directory: getURL(for: .Documents))
    }
    func listSharedProjects() -> [String]
    {
        return list(directory: getURL(for: .ApplicationInShared))
    }
    
    func findFile(in directory: AppDirectories) ->Bool
    {
        return exists(file: getURL(for: directory).appendingPathComponent(name))
    }
    
    
}

extension AppDirectoryNames
{
    func documentsDirectoryURL() -> URL
    {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        //return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func inboxDirectoryURL() -> URL
    {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(AppDirectories.Inbox.rawValue) // "Inbox")
    }
    
    func libraryDirectoryURL() -> URL
    {
        return FileManager.default.urls(for: FileManager.SearchPathDirectory.libraryDirectory, in: .userDomainMask).first!
    }
    
    func tempDirectoryURL() -> URL
    {
        return FileManager.default.temporaryDirectory
        //urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(AppDirectories.Temp.rawValue) //"tmp")
    }
    
    func projectDirectoryURL() -> URL
    {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(LandingPageViewController.projectName)
        //return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func sharedDirectoryURL() -> URL?
    {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.excelsiortechteam")
    }
    
    func applicationInSharedDirectoryURL() -> URL?
    {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.excelsiortechteam")?.appendingPathComponent(LandingPageViewController.applicationName)
    }
    
    func projectInSharedDirectoryURL() -> URL?
    {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.excelsiortechteam")?.appendingPathComponent(LandingPageViewController.applicationName).appendingPathComponent(LandingPageViewController.projectName)
    }
    func getURL(for directory: AppDirectories) -> URL
    {
        switch directory
        {
        case .Documents:
            return documentsDirectoryURL()
        case .Inbox:
            return inboxDirectoryURL()
        case .Library:
            return libraryDirectoryURL()
        case .Temp:
            return tempDirectoryURL()
        case .Project:
            return projectDirectoryURL()
        case .Shared:
            return sharedDirectoryURL()!
        case .ApplicationInShared:
            return applicationInSharedDirectoryURL()!
        case .ProjectInShared:
            return projectInSharedDirectoryURL()!
        }
        
    }
    
    func buildFullPath(forFileName name: String, inDirectory directory: AppDirectories) -> URL
    {
        return getURL(for: directory).appendingPathComponent(name)
    }
}




extension AppFileStatusChecking
{
    func isWritable(file at: URL) -> Bool
    {
        if FileManager.default.isWritableFile(atPath: at.path)
        {
            print(at.path)
            return true
        }
        else
        {
            print(at.path)
            return false
        }
    }
    
    func isReadable(file at: URL) -> Bool
    {
        if FileManager.default.isReadableFile(atPath: at.path)
        {
            print(at.path)
            return true
        }
        else
        {
            print(at.path)
            return false
        }
    }
    
    func exists(file at: URL) -> Bool
    {
        if FileManager.default.fileExists(atPath: at.path)
        {
            return true
        }
        else
        {
            return false
        }
    }
}



extension AppFileSystemMetaData
{
    func list(directory at: URL) -> [String]
    {
        if FileManager.default.fileExists(atPath: at.path){
            let listing = try! FileManager.default.contentsOfDirectory(atPath: at.path)
        
            if listing.count > 0
            {
                print("\n----------------------------")
                print("LISTING: \(at.path)")
                print("")
                for file in listing
                {
                    print("File: \(file.debugDescription)")
                }
                print("")
                print("----------------------------\n")
            }
            return listing
        }
        else{
            print("Directory doesn't exist")
            return []
        }
    }
    
    func attributes(ofFile atFullPath: URL) -> [FileAttributeKey : Any]
    {
        return try! FileManager.default.attributesOfItem(atPath: atFullPath.path)
    }
}




extension AppFileManipulation
{
    
    
    func createDirectory(at path: AppDirectories, withName name: String) -> Bool
    {
        let directoryPath = getURL(for: path).path + "/" + name
        print(directoryPath)
        if !FileManager.default.fileExists(atPath: directoryPath)
        {
            do
            {
                try FileManager.default.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
                return true
            }
            catch
            {
                NSLog("Error Creating Project Directory")
            }
        }
        return false
    }
    
    func createDocumentsDirectory(withName name: String) -> Bool{
        let directoryPath = documentsDirectoryURL()
        let applicationPath = (directoryPath.path) + "/" + LandingPageViewController.applicationName
        if !FileManager.default.fileExists(atPath: applicationPath)
        {
            do{
                try FileManager.default.createDirectory(atPath: applicationPath, withIntermediateDirectories: true, attributes: nil)
                print("Created New Application Directory inside Documents Directory")
            }
            catch{
                NSLog("Error occured while creating project folder")
            }
        }
        else { print("Application already exists inside Documents directory. Proceeed to create project directory")}
        
        
        let projectPath = applicationPath + "/" + name
        print("Shared path = ", projectPath)
        if !FileManager.default.fileExists(atPath: projectPath)
        {
            do
            {
                try FileManager.default.createDirectory(atPath: projectPath, withIntermediateDirectories: true, attributes: nil)
                print("Created new Project Directory inside documents application directory")
                return true
            }
            catch
            {
                NSLog("Path already exists. Choose a unique name for the Project")
            }
        }
        else
        {
            print("Project Directory already exists inside the Documents Application Directory. Please choose a unique name")
            return false
        }
        
        print("Fatal Error. Check Documents Directory")
        return false
    }
    
    
    
    func createSharedDirectory(withName name: String) -> Bool{
        let directoryPath = sharedDirectoryURL()
        if directoryPath != nil
        {
            
            let applicationPath = (directoryPath?.path)! + "/" + LandingPageViewController.applicationName
            if !FileManager.default.fileExists(atPath: applicationPath)
            {
                do{
                    try FileManager.default.createDirectory(atPath: applicationPath, withIntermediateDirectories: true, attributes: nil)
                    print("Created New Application Directory inside Shared Directory")
                }
                catch{
                    NSLog("Error occured while creating project folder")
                }
            }
            else { print("Application already exists inside Shared directory. Proceeed to create project directory")}
            
            
            let projectPath = applicationPath + "/" + name
            print("Shared path = ", projectPath)
            if !FileManager.default.fileExists(atPath: projectPath)
            {
                do
                {
                    try FileManager.default.createDirectory(atPath: projectPath, withIntermediateDirectories: true, attributes: nil)
                    print("Created new Project Directory inside shared application directory")
                    return true
                }
                catch
                {
                    NSLog("Path already exists. Choose a unique name for the Project")
                }
            }
            else
            {
                print("Project Directory already exists inside the Shared Application Directory. Please choose a unique name")
                return false
            }
        }
        print("Could Not Locate Shared Directory. Fatal Error")
        return false
    }
    
    func writeFile(containing: String, to path: URL, withName name: String) -> Bool
    {
        let filePath =  path.appendingPathComponent(name)
        let rawData: Data? = containing.data(using: .utf8)
        return FileManager.default.createFile(atPath: filePath.path, contents: rawData, attributes: nil)
    }
    
    func readFile(at path: AppDirectories, withName name: String) -> String
    {
        let filePath = getURL(for: path).path + "/" + name
        let fileContents = FileManager.default.contents(atPath: filePath)
        let fileContentsAsString = String(bytes: fileContents!, encoding: .utf8)
        print(fileContentsAsString!)
        return fileContentsAsString!
    }
    
    func deleteFile(at path: AppDirectories, withName name: String) -> Bool
    {
        let filePath = buildFullPath(forFileName: name, inDirectory: path)
        try! FileManager.default.removeItem(at: filePath)
        return true
    }
    
    func renameFile(at path: AppDirectories, with oldName: String, to newName: String) -> Bool
    {
        let oldPath = getURL(for: path).appendingPathComponent(oldName)
        let newPath = getURL(for: path).appendingPathComponent(newName)
        try! FileManager.default.moveItem(at: oldPath, to: newPath)
        
        // highlights the limitations of using return values
        return true
    }
    
    func moveFile(withName name: String, inDirectory: AppDirectories, toDirectory directory: AppDirectories) -> Bool
    {
        let originURL = buildFullPath(forFileName: name, inDirectory: inDirectory)
        let destinationURL = buildFullPath(forFileName: name, inDirectory: directory)
        // warning: constant 'success' inferred to have type '()', which may be unexpected
        // let success =
        try! FileManager.default.moveItem(at: originURL, to: destinationURL)
        return true
    }
    
    func copyFile(withName name: String, inDirectory: AppDirectories, toDirectory directory: AppDirectories) -> Bool
    {
        let originURL = buildFullPath(forFileName: name, inDirectory: inDirectory)
        let destinationURL = buildFullPath(forFileName: name+"1", inDirectory: directory)
        try! FileManager.default.copyItem(at: originURL, to: destinationURL)
        return true
    }
    
    func changeFileExtension(withName name: String, inDirectory: AppDirectories, toNewExtension newExtension: String) -> Bool
    {
        var newFileName = NSString(string:name)
        newFileName = newFileName.deletingPathExtension as NSString
        newFileName = (newFileName.appendingPathExtension(newExtension) as NSString?)!
        let finalFileName:String =  String(newFileName)
        
        let originURL = buildFullPath(forFileName: name, inDirectory: inDirectory)
        let destinationURL = buildFullPath(forFileName: finalFileName, inDirectory: inDirectory)
        
        try! FileManager.default.moveItem(at: originURL, to: destinationURL)
        
        return true
    }
}


