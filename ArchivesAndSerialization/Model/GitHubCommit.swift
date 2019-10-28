//
//  GitHubCommit.swift
//  ArchivesAndSerialization
//
//  Created by Curtis McCarthy on 10/17/19.
//  Copyright © 2019 Blue Evolutions. All rights reserved.
//

import Foundation

let json = """
[
    {
        "commit": {
            "author": {
                "name": "Monalisa Octocat",
                "email": "support@github.com",
                "date": "2011-04-14T16:00:49Z"
            },

            "message": "Fix all the bugs",
            "comment_count": 0,
        },

        "sha": "6dcb89b5b57875f334f61aebed695e2e4193d",
        "url": "https://api.github.com/repos/octocat/"
    }
]
""".data(using: .utf8)!

let json2 = """
[
    {
        "commit": {
            "author": {
                "name": "Curt McCarthy",
                "email": "beDevCurt@gmail.com",
                "date": "2019-10-18T16:00:49Z"
            },

            "message": "This is Curt's commit. Back off.",
            "comment_count": 2,
        },

        "sha": "6dcb89b5b5738228382bed695e2e4193d",
        "url": "https://api.github.com/repos/octocat/"
    }
]
""".data(using: .utf8)!

let json3 = """
[
    {
        "commit": {
            "author": {
                "name": "Declan McCarthy",
                "email": "beDevDeclan@gmail.com",
                "date": "2015-01-06T16:00:49Z"
            },

            "message": "This is Declan's commit. It's super fast.",
            "comment_count": 55,
        },

        "sha": "6dcb89b5b4f61aebf334f61aebed695e2e4193d",
        "url": "https://api.github.com/repos/octocat/"
    }
]
""".data(using: .utf8)!

let jsons = [json, json2, json3]

struct Author: Codable {
    let name: String
    let email: String
//    let date: Date
    let date: String
    
    init(name: String?, email: String?, date: String?) {
        if let name = name {
            self.name = name
        } else {
            self.name = "Unnamed Author"
        }
        
        if let email = email {
            self.email = email
        } else {
            self.email = "No email provided"
        }
        
        if let date = date {
            self.date = date
        } else {
            self.date = Date().description
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case email
        case date
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(email, forKey: .email)
        try container.encode(date, forKey: .date)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        email = try container.decode(String.self, forKey: .email)
        date = try container.decode(String.self, forKey: .date)
    }
}

struct Commit: Codable {
    let author: Author
//        let url: URL?
    let message: String
    let commentCount: Int
    
    init(author: Author?, message: String?, commentCount: Int?) {
        if let author = author {
            self.author = author
        } else {
            self.author = Author(name: nil, email: nil, date: nil)
        }
        
        if let message = message {
            self.message = message
        } else {
            self.message = "No message added."
        }
        
        if let commentCount = commentCount {
            self.commentCount = commentCount
        } else {
            self.commentCount = 0
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case author
//            case url
        case message
        case commentCount = "comment_count"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        /*
        url = try container.decode(URL.self, forKey: .url)
        // You can do additional customization of how the object is built from the passed in data.
        guard url?.scheme == "https" else {
            throw DecodingError.dataCorrupted(DecodingError.Context(
                codingPath: container.codingPath + [CodingKeys.url],
                debugDescription: "URLs require https")
            )
        }
*/
        message = try container.decode(String.self, forKey: .message)
        author = try container.decode(Author.self, forKey: .author)
        commentCount = try container.decode(Int.self, forKey: .commentCount)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
//            try container.encode(url, forKey: .url)
        try container.encode(author, forKey: .author)
        try container.encode(message, forKey: .message)
        try container.encode(commentCount, forKey: .commentCount)
    }
}

struct GitHubCommit: Codable {
    let info: Commit
    let sha: String
    let url: URL?
    let id: String
    
    init(info: Commit?, sha: String?, url: URL?, id: String = UUID().uuidString) {
        if let info = info {
            self.info = info
        } else {
            self.info = Commit(author: nil, message: nil, commentCount: nil)
        }
        
        if let sha = sha {
            self.sha = sha
        } else {
            self.sha = "No SHA available"
        }
        
        self.url = url
        self.id = id
    }
    
    private enum CodingKeys: String, CodingKey {
        case info = "commit"
        case sha
        case url = "SUBTLE TYPO"
        case id
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        info = try container.decode(Commit.self, forKey: .info)
        sha = try container.decode(String.self, forKey: .sha)
        url = try? container.decode(URL.self, forKey: .url)
        if let fetchedID = try? container.decode(String.self, forKey: .id) {
            id = fetchedID
        } else {
            id = UUID().uuidString
        }
    }
}

