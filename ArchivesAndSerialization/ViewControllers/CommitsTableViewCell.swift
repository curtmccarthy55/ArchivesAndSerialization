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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
