//
//  AuthManager.swift
//  Swift Spotify Clone
//
//  Created by Олег Ефимов on 20.12.2021.
//

import Foundation

final class AuthManager {
    
    public static let shared = AuthManager()
    
    private init() {}
    
    public var signInURL: URL? {
        let baseURL = "https://accounts.spotify.com/authorize?"
        let scopes = "user-read-private"
        let redirectURI = "https://task-list-app.vercel.app"
        let query = "response_type=code" +
        "&client_id=\(Keys.clientId)&scope=\(scopes)" +
         "&redirect_uri=\(redirectURI)&show_dialog=true"
        return URL(string: baseURL + query)
    }
    
    public var isSignedIn: Bool {
        return false
    }
    
    private var accessToken: String? {
        return nil
    }
    
    private var refreshToken: String? {
        return nil
    }
    
    private var expirationDate: Date? {
        return nil
    }
    
    private var shouldRefreshToken: Bool {
        return false
    }
    
    public func exchangeCodeForToken(_ code: String, completion: @escaping (Bool) -> Void) {
        //get token
    }
    
    public func refreshAccessToken() {
        
    }
    
    public func saveToket(){
        
    }
}
