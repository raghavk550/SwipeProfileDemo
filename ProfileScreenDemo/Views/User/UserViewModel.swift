//
//  UserViewModel.swift
//  ProfileScreenDemo
//
//  Created by Raghav Kakria on 18/08/25.
//


import Foundation
import Combine

class UserViewModel: ObservableObject {
    @Published var users: [UserModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let service: UserServiceProtocol
    
    init(service: UserServiceProtocol = UserService()) {
        self.service = service
    }
    
    func fetchUsers() {
        isLoading = true
        errorMessage = nil
        
        service.fetchUsers()
            .sink { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] users in
                self?.users = users
            }
            .store(in: &cancellables)
    }
}
