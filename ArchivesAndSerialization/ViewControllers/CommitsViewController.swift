//
//  ViewController.swift
//  ArchivesAndSerialization
//
//  Created by Curtis McCarthy on 10/16/19.
//  Copyright © 2019 Blue Evolutions. All rights reserved.
//

import UIKit

class CommitsViewController: UIViewController {
    let REUSE_IDENTIFIER = "reuseIdentifier"
    
    //MARK: Properties
    @IBOutlet weak var commitsTable: UITableView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
//    var commits: [GitHubCommit] = []
    var repository: Repository?
    
    //MARK: - Presenting Data
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellNib = UINib(nibName: "CommitsTableViewCell", bundle: nil)
        commitsTable.register(cellNib, forCellReuseIdentifier: REUSE_IDENTIFIER)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        repository = prepRepository()
        if let ids = repository?.commitIDs, ids.count > 0 {
            let decoder = JSONDecoder()
            for id in ids {
                do {
                    let commitData = ArchiveService.shared.fetchCommit(withID: id)
                    let commit = try decoder.decode(GitHubCommit.self, from: commitData)
                    repository?.addCommit(commit)
                }
                catch {
                    print("unable to fetch commit with ID: \(id)")
                }
            }
            commitsTable.reloadData()
        }
    }
    
    func prepRepository() -> Repository {
        if let data = fetchRepositoryData() {
            return decodeRepositoryData(data)
        } else {
            return Repository()
        }
    }
    
    func decodeRepositoryData(_ data: Data) -> Repository {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            return try decoder.decode(Repository.self, from: data)
        }
        catch DecodingError.keyNotFound(let key, let context) {
            // case url = "SUBTLE TYPO", but the json key for the url value is "url"
            // when url's type is URL (non-optional), this prints 'Missing key: CodingKeys(stringValue: "SUBTLE TYPO", intValue: nil)'
            // when url's type is URL?, url's value is set to nil
            print("Missing key: \(key)")
            print("Debug description: \(context.debugDescription)")
            return Repository()
        }
        catch DecodingError.valueNotFound(let type, let context) {
            // indicates that we tried to decode something of this type, but in fact found nil.
            print("type == \(type)")
            print("context == \(context)")
            return Repository()
        }
        catch DecodingError.typeMismatch(let type, let context) {
            // indicates that we tried to decode something of this type, but something else was found in the payload.  For example, you tried to decode a string, but instead found an int.
            print("type == \(type)")
            print("context == \(context)")
            return Repository()
        }
        catch {
            let alert = UIAlertController(title: "Unable to Fetch Repository",
                                        message: error.localizedDescription,
                                 preferredStyle: .alert)
            let dismiss = UIAlertAction(title: "Dismiss", style: .default)
            alert.addAction(dismiss)
            present(alert, animated: true)
            return Repository()
        }
    }
    
    @IBAction func tappedSave() {
        saveData()
    }
    
    @IBAction func tappedAdd() {
        let data = jsons.randomElement()!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            let commit = try decoder.decode([GitHubCommit].self, from: data)
            repository?.addCommit(commit.first!)
            commitsTable.reloadData()
        }
        catch DecodingError.keyNotFound(let key, let context) {
            // case url = "SUBTLE TYPO", but the json key for the url value is "url"
            // when url's type is URL (non-optional), this prints 'Missing key: CodingKeys(stringValue: "SUBTLE TYPO", intValue: nil)'
            // when url's type is URL?, url's value is set to nil
            print("Missing key: \(key)")
            print("Debug description: \(context.debugDescription)")
        }
        catch DecodingError.valueNotFound(let type, let context) {
            // indicates that we tried to decode something of this type, but in fact found nil.
            print("type == \(type)")
            print("context == \(context)")
        }
        catch DecodingError.typeMismatch(let type, let context) {
            // indicates that we tried to decode something of this type, but something else was found in the payload.  For example, you tried to decode a string, but instead found an int.
            print("type == \(type)")
            print("context == \(context)")
        }
        catch {
            let alert = UIAlertController(title: "Unable to Fetch Commits",
                                        message: error.localizedDescription,
                                 preferredStyle: .alert)
            let dismiss = UIAlertAction(title: "Dismiss", style: .default)
            alert.addAction(dismiss)
            present(alert, animated: true)
        }
    }
    
    @IBAction func tappedDeleteAll() {
        deleteAll()
    }

    //MARK: - Read/Write
    func fetchRepositoryData() -> Data? {
        return ArchiveService.shared.fetchRepository()
    }
    
    func fetchCommitData() -> Data {
        return ArchiveService.shared.fetchCommits()
    }

    func saveData() {
//        ArchiveService.shared.saveCommits(commits)
        if let commits = repository?.commits {
            ArchiveService.shared.saveRepository(repository!)
            for commit in commits {
                ArchiveService.shared.saveCommit(commit)
            }
        }
    }
    
    func deleteCommitAt(indexPath: IndexPath) {
        guard let doomedCommit = repository?.commits[indexPath.row] else { return }
        repository?.removeCommitAt(index: indexPath.row)
        
        ArchiveService.shared.removeCommit(doomedCommit)
        ArchiveService.shared.saveRepository(repository!)
    }
    
    func deleteAll() {
        guard let commits = repository?.commits else {
            return
        }
        for (index, commit) in commits.enumerated().reversed() {
            repository?.removeCommitAt(index: index)
            ArchiveService.shared.removeCommit(commit)
        }
        
        ArchiveService.shared.saveRepository(repository!)
        commitsTable.reloadData()
    }
}

extension CommitsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        deleteCommitAt(indexPath: indexPath)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.reloadData()
    }
}

extension CommitsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repository?.commits.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: REUSE_IDENTIFIER, for: indexPath) as! CommitsTableViewCell
        setUpCell(&cell, at: indexPath)
        
        return cell
    }
    
    func setUpCell(_ cell: inout CommitsTableViewCell, at indexPath: IndexPath) {
        guard let commit = repository?.commits[indexPath.row] else {
            cell.authorLabel.text = "Author Not Found"
            cell.messageLabel.text = "Message Not Found"
            cell.shaLabel.text = "SHA Not Found"
            return
        }
        cell.authorLabel.text = commit.info.author.name
        cell.messageLabel.text = commit.info.message
        cell.shaLabel.text = "SHA: \(commit.sha.prefix(10))"
    }
}

