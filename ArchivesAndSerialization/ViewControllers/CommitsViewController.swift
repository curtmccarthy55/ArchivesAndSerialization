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

    var repository: Repository?
    
    //MARK: - Scene Set Up
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellNib = UINib(nibName: "CommitsTableViewCell", bundle: nil)
        commitsTable.register(cellNib, forCellReuseIdentifier: REUSE_IDENTIFIER)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        repository = fetchRepository() 
        if let ids = repository?.commitIDs, ids.count > 0 {
            for id in ids {
                do {
                    let commit = try ArchiveService.shared.fetchCommit(withID: id)
                    repository?.addCommit(commit)
                }
                catch {
                    handleError(error)
                }
            }
            commitsTable.reloadData()
        }
    }
    
    //MARK: - Button Actions
    
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
        catch {
            handleError(error)
        }
    }
    
    @IBAction func tappedDeleteAll() {
        deleteAll()
    }

    //MARK: - Read
    func fetchRepository() -> Repository {
        do {
            return try ArchiveService.shared.fetchRepository()
        }
        catch {
            handleError(error)
        }
        return Repository()
    }

    //MARK: - Write
    func saveData() {
        if let commits = repository?.commits {
            ArchiveService.shared.saveRepository(repository!)
            for commit in commits {
                ArchiveService.shared.saveCommit(commit)
            }
        }
    }
    
    //MARK: - Delete
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
    
    func handleError(_ error: Error) {
        switch error {
        case SerializationError.missingData:
            print("ArchiveService was unable to fetch Repository data.")
        case DecodingError.keyNotFound(let key, let context) :
            // case url = "SUBTLE TYPO", but the json key for the url value is "url"
            // when url's type is URL (non-optional), this prints 'Missing key: CodingKeys(stringValue: "SUBTLE TYPO", intValue: nil)'
            // when url's type is URL?, url's value is set to nil
            print("Missing key: \(key)")
            print("Debug description: \(context.debugDescription)")
        case DecodingError.valueNotFound(let type, let context):
            // indicates that we tried to decode something of this type, but in fact found nil.
            print("type == \(type)")
            print("context == \(context)")
        case DecodingError.typeMismatch(let type, let context):
            // indicates that we tried to decode something of this type, but something else was found in the payload.  For example, you tried to decode a string, but instead found an int.
            print("type == \(type)")
            print("context == \(context)")
        default:
            let alert = UIAlertController(title: "Unknown Error Occurred",
                                        message: error.localizedDescription,
                                 preferredStyle: .alert)
            let dismiss = UIAlertAction(title: "Dismiss", style: .default)
            alert.addAction(dismiss)
            present(alert, animated: true)
        }
    }
}

//MARK: - TableView Delegate
extension CommitsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        deleteCommitAt(indexPath: indexPath)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.reloadData()
    }
}

//MARK: - TableView DataSource
extension CommitsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repository?.commits.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: REUSE_IDENTIFIER,
                                                            for: indexPath) as! CommitsTableViewCell
        let commit = repository?.commits[indexPath.row]
        cell.configure(withCommit: commit)
        
        return cell
    }
}

