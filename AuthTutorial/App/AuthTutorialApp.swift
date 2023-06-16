//
//  AuthTutorialApp.swift
//  AuthTutorial
//
//  Created by Halil YAŞ on 14.06.2023.
//

import SwiftUI
import Firebase

@main
struct AuthTutorialApp: App {
    @StateObject var viewModel = AuthViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
