//
//  Posts.swift
//  BeRealClone
//
//  Created by Ujjwal Adhikari on 2/26/23.
//

import Foundation
import ParseSwift
import CoreLocation

struct Post: ParseObject {
    // These are required by ParseObject
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?
    
    // Your own custom properties.
    var caption: String?
    var location: String?
    var user: User?
    var imageFile: ParseFile?
//
}
