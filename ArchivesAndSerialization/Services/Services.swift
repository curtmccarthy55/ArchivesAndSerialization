//
//  Services.swift
//  ArchivesAndSerialization
//
//  Created by Curtis McCarthy on 10/17/19.
//  Copyright © 2019 Blue Evolutions. All rights reserved.
//

import Foundation

class ArchiveService {
    let reposPath = "/repositories"
    let commitsPath = "/commits"
    
    private init() {}
    static let shared = ArchiveService()
    private var commitsDirectoryExists = false
    
    //MARK: - File Pathing
    func documentsDirectory() -> String {
        let paths: Array = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        //Apple suggests using URLs instead of strings for file management
        //        let urlPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let documentsDirectory = paths.first
        return documentsDirectory!
    }
    
    func absolutePathFromRelativePath(_ path: String) -> String {
        let directory = documentsDirectory()
        let absolutePath = directory.appending(path)
        return absolutePath
    }
    
    //MARK: - Read
    func readObjectFromRelativePath(_ path: String) -> Any? {
        let absolutePath = absolutePathFromRelativePath(path)
        
        var object: Any?
        if FileManager.default.fileExists(atPath: absolutePath) {
            object = NSKeyedUnarchiver.unarchiveObject(withFile: absolutePath)
        }
        return object
    }
    
    func oldReadObjectFromRelativePath(_ path: String) -> Data? {
        let absolutePath = absolutePathFromRelativePath(path)
        
        var data: Data?
        if FileManager.default.fileExists(atPath: absolutePath) {
            let url = URL(fileURLWithPath: absolutePath)
            data = try? Data(contentsOf: url)
        }
        return data
    }
    
    func fetchCommit(withID id: String) -> Data {
        /*
        guard let data = readObjectFromRelativePath(commitsPath + "/" + id) else {
            return jsons.randomElement()!
        }
        return data
 */
        
        // replacing with above
        let unarchived = readObjectFromRelativePath(commitsPath + "/" + id)
        
        if let data = unarchived as? Data {
            return data
        }
        return jsons.randomElement()!
 
    }
    
    func fetchCommits() -> Data {
        /*
        guard let data = readObjectFromRelativePath(commitsPath) else {
            return  jsons.randomElement()!
        }
        return data
        */
        
        // replacing with above.
        let unarchived = readObjectFromRelativePath(commitsPath)
        
        if let data = unarchived as? Data {
            return data
            /*
            do {
                let decoder = JSONDecoder()
                let commits = try decoder.decode([GitHubCommit].self, from: data)
                print("commit decoding succeeded.")
                return commits
            }
            catch {
                print("commit decoding failed")
                return jsons.randomElement()!
            }
             */
        }
        return jsons.randomElement()!
 
    }
    
    func fetchRepository() -> Data? {
        /*
        guard let data = readObjectFromRelativePath(reposPath) else {
            return nil
        }
        return data
        */
        
        //
        let unarchived = readObjectFromRelativePath(reposPath)
        
        if let data = unarchived as? Data {
            return data
        } else {
            let encoder = JSONEncoder()
            do {
                let data = try encoder.encode(Repository())
                return data
            }
            catch {
                print("failed to return data for a Repository instance.")
                return nil
            }
        }
 
    }
    
    //MARK: - Write
    func saveRepository(_ repo: Repository) {
        let encoder = JSONEncoder()
        do {
            let repoData = try encoder.encode(repo)
            let filePath = absolutePathFromRelativePath(reposPath)
            print("repository save path: \(filePath)")
            let success = writeObject(repoData, toRelativePath: filePath)
            print("Repository write: \(success ? "successful" : "failed").")
        }
        catch {
            print("failed to save repository.  error == \(error.localizedDescription)")
        }
    }
    
    func verifyCommitDirectory() {
        let filePath = absolutePathFromRelativePath(commitsPath)
        if !FileManager.default.fileExists(atPath: filePath) {
            do {
                try FileManager.default.createDirectory(atPath: filePath, withIntermediateDirectories: false, attributes: nil)
                commitsDirectoryExists = true
                print("commits directory creation succeeded.")
            }
            catch {
                print("Unable to create /commits directory. error == \(error.localizedDescription)")
            }
        }
    }
    
    func saveCommit(_ commit: GitHubCommit) {
        if !commitsDirectoryExists {
            verifyCommitDirectory()
        }
        let encoder = JSONEncoder()
        do {
            let commitData = try encoder.encode(commit)
            let filePath = absolutePathFromRelativePath(commitsPath) + "/" + commit.id
            print("commit save path: \(filePath)")
            let success = writeObject(commitData, toRelativePath: filePath)
            print("Commit write: \(success ? "successful" : "failed").")
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func saveCommits(_ commits: [GitHubCommit]) {
        let encoder = JSONEncoder()
        do {
            let commitData = try encoder.encode(commits)
            let filePath = absolutePathFromRelativePath(commitsPath)
            writeObject(commitData, toRelativePath: filePath)
        }
        catch {
            print("Commit encoding failed with error: \(error.localizedDescription)")
        }
    }
    
    @discardableResult
    func writeObject(_ data: Any, toRelativePath filePath: String) -> Bool {
        return NSKeyedArchiver.archiveRootObject(data, toFile: filePath)
    }
    
    @discardableResult
    func oldWriteObject(_ data: Any, toRelativePath filePath: String) -> Bool { //cjm archiving
        let url = URL(fileURLWithPath: filePath)
        do {
            let archivedData = try NSKeyedArchiver.archivedData(withRootObject: data,
                                                         requiringSecureCoding: false)
            try archivedData.write(to: url)
            print("Successfully wrote object to disk.")
            return true
        }
        catch {
            print("Error writing object: \(error.localizedDescription)")
            return false
        }
    }
    
    //MARK: - Delete
    func removeCommit(_ commit: GitHubCommit) {
        let filePath = absolutePathFromRelativePath(commitsPath) + "/" + commit.id
        
        if FileManager.default.fileExists(atPath: filePath) {
            do {
                try FileManager.default.removeItem(atPath: filePath)
                print("successfully removed commit with id \(commit.id)")
            }
            catch {
                print("error removing item at: \(filePath)")
            }
        }
    }
    
    func removeData(at url: URL?) { //cjm pdf viewer
        if let confirmedURL = url {
            if FileManager.default.fileExists(atPath: confirmedURL.absoluteString) {
                do {
                    try FileManager.default.removeItem(at: confirmedURL)
                } catch {
                    print("error removing item at URL: \(confirmedURL)")
                }
            }
        }
    }
    
}
