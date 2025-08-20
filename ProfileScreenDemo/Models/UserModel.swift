//
//  UserModel.swift
//  ProfileScreenDemo
//
//  Created by Raghav Kakria on 18/08/25.
//

import Foundation

struct UserModel: Identifiable, Codable, Hashable {
    let id: Int
    let firstName: String?
    let lastName: String?
    let name: String?
    let email: String?
    let avatar: String?
    var fullName: String {
        "\(firstName ?? "") \(lastName ?? "")"
    }
}
