//
//  UserServiceProtocol.swift
//  ProfileScreenDemo
//
//  Created by Raghav Kakria on 18/08/25.
//


import Foundation
import Combine

protocol UserServiceProtocol {
    func fetchUsers() -> AnyPublisher<[UserModel], Error>
}

class UserService: UserServiceProtocol {
    func fetchUsers() -> AnyPublisher<[UserModel], Error> {
        guard let url = URL(string: "https://api.escuelajs.co/api/v1/users?limit=5") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [UserModel].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main) // ensure UI updates on main thread
            .eraseToAnyPublisher()
    }
}
