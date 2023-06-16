//
//  AuthViewModel.swift
//  AuthTutorial
//
//  Created by Halil YAŞ on 14.06.2023.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession : FirebaseAuth.User? // kullanıcı oturum açıp açmadığınız söyleyecek
    @Published var currentUser : User?
    
    init() {
        self.userSession = Auth.auth().currentUser // bunu yapmamızın nedeni uygulama açıldığında tekrardan profil varsa çalışmalı
        
        Task {
            await fetchUser() //Kullanıcının verilerini getiriyoruz
        }
    }
    
    func signIn(withEmail email : String,password : String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
        } catch {
            print("DEBUG: Failed to log in with error \(error.localizedDescription)")
        }
    }
    
    func createUser(withEmail email : String,password : String, fullname : String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user // burda kullanıcımız olduğunuz anlayacak
            let user = User(id: result.user.uid, fullname: fullname, email: email)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            await fetchUser() // Profil Oluşturduktan sonra Sayfa geldiğinde veriler gelsin diye bunu burda yapıyoruz.
        } catch {
            print("DEBUG: Failed to create user with error \(error.localizedDescription)")
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut() //signs out user on backend
            self.userSession = nil // wipes out user session and takes us back to login screen
            self.currentUser = nil // wipes out current user data model
        } catch {
            print("DEBUG: Faild to sign out with error \(error.localizedDescription)")
        }
    }
    
    func deleteAccount() {
        
    }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
        self.currentUser = try? snapshot.data(as: User.self)
    }
}
