//
//  UserDetailView.swift
//  ProfileScreenDemo
//
//  Created by Raghav Kakria on 20/08/25.
//

import SwiftUI

struct UserDetailView: View {
    let user: UserModel
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: user.avatar ?? "")) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .clipped()
                    .cornerRadius(20)
                    .shadow(radius: 3)
            } placeholder: {
                ProgressView()
            }
            Text(user.name ?? "No name")
                .font(.largeTitle)
            Text(user.email ?? "No email")
                .font(.title)
        }
        .padding()
    }
}

#Preview {
    UserDetailView(user: UserModel(id: 0, firstName: "John", lastName: "Test", name: "John Test", email: "jogntest@test.com", avatar: ""))
}
