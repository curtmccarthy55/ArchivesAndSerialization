//
//  Repository.swift
//  ArchivesAndSerialization
//
//  Created by Curtis McCarthy on 10/24/19.
//  Copyright © 2019 Blue Evolutions. All rights reserved.
//

import Foundation

struct Repository: Codable {
    /// Contains `id` values for all commits belonging to the repository.
    var commitIDs: [String] = []
    private(set) var commits: [GitHubCommit] = []
    
    enum CodingKeys: CodingKey {
        case commitIDs
    }
    
    mutating func addCommit(_ commit: GitHubCommit) {
        commits.append(commit)
        if !commitIDs.contains(commit.id) {
            commitIDs.append(commit.id)
        }
    }
    
    mutating func removeCommitAt(index: Int) {
        commits.remove(at: index)
        commitIDs.remove(at: index)
    }
}
