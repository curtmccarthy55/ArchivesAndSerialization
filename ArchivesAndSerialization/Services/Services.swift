//
//  Services.swift
//  ArchivesAndSerialization
//
//  Created by Curtis McCarthy on 10/17/19.
//  Copyright © 2019 Blue Evolutions. All rights reserved.
//

import Foundation

enum SerializationError: Error {
    case missingData
}

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
    /* Formerly used, now deprecated, read function.
    func oldReadObjectFromRelativePath(_ path: String) -> Any? {
        let absolutePath = absolutePathFromRelativePath(path)
        
        var object: Any?
        if FileManager.default.fileExists(atPath: absolutePath) {
            // 'unarchiveObject(withFile:)' was deprecated in iOS 12.0: Use +unarchivedObjectOfClass:fromData:error: instead
            object = NSKeyedUnarchiver.unarchiveObject(withFile: absolutePath)
        }
        return object
    }
 */
    
    func readObjectFromRelativePath(_ path: String) -> Data? {
        let absolutePath = absolutePathFromRelativePath(path)
        
        var data: Data?
        if FileManager.default.fileExists(atPath: absolutePath) {
            let url = URL(fileURLWithPath: absolutePath)
            data = try? Data(contentsOf: url)
        }
        return data
    }
    
    func fetchRepository() throws -> Repository { //cjm read repository
        guard let data = readObjectFromRelativePath(reposPath) else {
            print("Repository data not found.")
            throw SerializationError.missingData
        }
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let repo = try decoder.decode(Repository.self, from: data)
            print("Successfully fetched Repository.")
            return repo
        }
        catch {
            throw error
        }
    }
    
    func fetchCommit(withID id: String) throws -> GitHubCommit {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard let data = readObjectFromRelativePath(commitsPath + "/" + id) else {
            let data = jsons.randomElement()!
            return try! decoder.decode(GitHubCommit.self, from: data)
        }
        
        do {
            return try decoder.decode(GitHubCommit.self, from: data)
        }
        catch {
            throw error
        }
        
        
//        guard let data = readObjectFromRelativePath(commitsPath + "/" + id) else {
//            return jsons.randomElement()!
//        }
//        return data
    }
    
    //MARK: - Write
    /* Formerly used, now deprecated, write method.
    @discardableResult
    func oldWriteObject(_ data: Any, toRelativePath filePath: String) -> Bool {
        return NSKeyedArchiver.archiveRootObject(data, toFile: filePath)
    }
 */
    
    @discardableResult
    func writeObject(_ data: Data, toRelativePath relativePath: String) -> Bool { //cjm archiving
        let filePath = absolutePathFromRelativePath(relativePath)
        let url = URL(fileURLWithPath: filePath)
        do {
            try data.write(to: url)
            print("Successfully wrote object to path: \(filePath).")
            return true
        }
        catch {
            print("Error writing object: \(error.localizedDescription)")
            return false
        }
    }
    
    func saveRepository(_ repo: Repository) {
        let encoder = JSONEncoder()
        do {
            let repoData = try encoder.encode(repo)
            let success = writeObject(repoData, toRelativePath: reposPath)
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
            let filePath = commitsPath + "/" + commit.id
            print("commit save path: \(filePath)")
            let success = writeObject(commitData, toRelativePath: filePath)
            print("Commit write: \(success ? "successful" : "failed").")
        }
        catch {
            print("encode GitHubCommit failed with error: \(error.localizedDescription)")
        }
    }
    
    func saveCommits(_ commits: [GitHubCommit]) {
        let encoder = JSONEncoder()
        do {
            let commitData = try encoder.encode(commits)
            writeObject(commitData, toRelativePath: commitsPath)
        }
        catch {
            print("Commit encoding failed with error: \(error.localizedDescription)")
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
