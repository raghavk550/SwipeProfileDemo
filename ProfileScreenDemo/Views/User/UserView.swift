//
//  UserView.swift
//  ProfileScreenDemo
//
//  Created by Raghav Kakria on 18/08/25.
//

import SwiftUI

struct UserView: View {
    @StateObject private var viewModel = UserViewModel()
    @State private var topCardOffset: CGSize = .zero
    @State private var selectedUser: UserModel?
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading users...")
                } else {
                    if viewModel.users.count > 0 {
                        Spacer(minLength: 30)
                        ZStack {
                            ForEach(Array(viewModel.users.enumerated()), id: \.element.id) { index, profile in
                                cardView(for: profile, at: index)
                            }
                        }
                        .frame(height: 500)
                        
                        Spacer()
                    }
                    else {
                        Text("That's all folks!")
                            .font(.title)
                            .bold()
                            .shadow(radius: 3)
                    }
                }
            }
            .onAppear {
                viewModel.fetchUsers()
            }
            .navigationDestination(item: $selectedUser) { user in
                UserDetailView(user: user)
            }
            .navigationTitle("Profile")
        }
    }
    
    // MARK: - Card Builder
    
    private func cardView(for user: UserModel, at index: Int) -> some View {
        let userCount = viewModel.users.count
        let isTopCard = index == userCount - 1
        let offsetValue = CGFloat(userCount - 1 - index) * 10
        let scaleValue  = 1 - CGFloat(userCount - 1 - index) * 0.05
        
        return SwipeCardView(
            profile: user,
            topCardOffset: isTopCard ? $topCardOffset : .constant(.zero)
        ) { removedProfile, liked in
            swipe(direction: liked ? .right : .left, forceProfile: removedProfile)
            topCardOffset = .zero
        }
        .scaleEffect(scaleValue)
        .offset(y: offsetValue)
        .zIndex(Double(index))
        .allowsHitTesting(isTopCard)
        .onTapGesture {
            selectedUser = user
        }
    }
    
    // MARK: - Swipe Handler
    
    private enum SwipeDirection {
        case left, right
    }
    
    private func swipe(direction: SwipeDirection, forceProfile: UserModel? = nil) {
        guard let topProfile = forceProfile ?? viewModel.users.last else { return }
        
        let targetOffset = direction == .left ? CGSize(width: -1000, height: 0) : CGSize(width: 1000, height: 0)
        
        withAnimation(.spring()) {
            topCardOffset = targetOffset
        }
        
        DispatchQueue.main.async {
            viewModel.users.removeAll { $0.id == topProfile.id }
        }
    }
}

// MARK: - SwipeCardView

struct SwipeCardView: View {
    let profile: UserModel
    @Binding var topCardOffset: CGSize
    var onRemove: (_ profile: UserModel, _ like: Bool) -> Void
    let threshold: CGFloat   // now configurable, no "private" initializer issues
    
    init(
        profile: UserModel,
        topCardOffset: Binding<CGSize>,
        threshold: CGFloat = 120,
        onRemove: @escaping (_ profile: UserModel, _ like: Bool) -> Void
    ) {
        self.profile = profile
        self._topCardOffset = topCardOffset
        self.threshold = threshold
        self.onRemove = onRemove
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottomLeading) {
                // Background image
                AsyncImage(url: URL(string: profile.avatar ?? "")) { phase in
                    switch phase {
                    case .empty:
                        ProgressView() // loader while downloading
                            .frame(width: 50, height: 50)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width * 0.9, height: geo.size.height * 0.75)
                            .clipped()
                            .cornerRadius(20)
                            .shadow(radius: 3)
                            .overlay(labelsOverlay)
                    case .failure:
                        Image("profile1")
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width * 0.9, height: geo.size.height * 0.75)
                            .clipped()
                            .cornerRadius(20)
                            .shadow(radius: 5)
                            .overlay(labelsOverlay)
                    @unknown default:
                        EmptyView()
                    }
                }
                
                // Profile info
                VStack(alignment: .leading) {
                    Text("\(profile.name ?? "No name")")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                        .shadow(radius: 3)
                }
                .padding()
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .offset(x: topCardOffset.width, y: topCardOffset.height * 0.1)
            .rotationEffect(.degrees(Double(topCardOffset.width / 20)))
            .gesture(dragGesture)
            .animation(.spring(), value: topCardOffset)
        }
    }
    
    // MARK: - Overlays
    private var labelsOverlay: some View {
        ZStack {
            Text("LIKE")
                .font(.system(size: 40, weight: .heavy))
                .foregroundColor(.green)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.green, lineWidth: 4))
                .opacity(topCardOffset.width > 0 ? Double(min(topCardOffset.width / threshold, 1)) : 0)
                .rotationEffect(.degrees(-20))
                .offset(x: 60, y: -120)
            
            Text("NOPE")
                .font(.system(size: 40, weight: .heavy))
                .foregroundColor(.red)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.red, lineWidth: 4))
                .opacity(topCardOffset.width < 0 ? Double(min(-topCardOffset.width / threshold, 1)) : 0)
                .rotationEffect(.degrees(20))
                .offset(x: -60, y: -120)
        }
    }
    
    // MARK: - Drag Gesture
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { gesture in
                topCardOffset = gesture.translation
            }
            .onEnded { _ in
                if topCardOffset.width > threshold {
                    onRemove(profile, true)
                } else if topCardOffset.width < -threshold {
                    onRemove(profile, false)
                } else {
                    withAnimation(.spring()) {
                        topCardOffset = .zero
                    }
                }
            }
    }
}

#Preview {
    UserView()
}
