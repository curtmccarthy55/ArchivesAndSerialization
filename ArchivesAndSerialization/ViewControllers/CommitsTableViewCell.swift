//
//  CommitsTableViewCell.swift
//  ArchivesAndSerialization
//
//  Created by Curtis McCarthy on 10/16/19.
//  Copyright © 2019 Blue Evolutions. All rights reserved.
//

import UIKit

class CommitsTableViewCell: UITableViewCell {
    //MARK: Properties
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var shaLabel: UILabel!
    
    func configure(withCommit commit: GitHubCommit?) {
        guard let commit = commit else {
            authorLabel.text = "Author Not Found"
            messageLabel.text = "Message Not Found"
            shaLabel.text = "SHA Not Found"
            return
        }
        authorLabel.text = commit.info.author.name
        messageLabel.text = commit.info.message
        shaLabel.text = "SHA: \(commit.sha.prefix(10))"
    }
    
}
