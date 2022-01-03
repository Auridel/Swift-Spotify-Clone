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
    
    private let tokenApiURL = "https://accounts.spotify.com/api/token"
    private let redirectURI = "https://task-list-app.vercel.app"
    private let scopes = "user-read-private%20playlist-modify-public%20playlist-read-private" +
        "%20playlist-modify-private%20user-follow-read" +
        "%20user-library-modify%20user-library-read%20user-read-email"
    
    private var isRefreshing = false {
        didSet {
            guard let token = accessToken, !isRefreshing else {
                return
            }
            for completion in onResreshBlocks {
                completion(token)
            }
        }
    }
    
    private var onResreshBlocks = [((String) -> Void)]()
    
    public var signInURL: URL? {
        let baseURL = "https://accounts.spotify.com/authorize?"
        let query = "response_type=code" +
        "&client_id=\(Keys.clientId)&scope=\(scopes)" +
        "&redirect_uri=\(redirectURI)&show_dialog=true"
        return URL(string: baseURL + query)
    }
    
    public var isSignedIn: Bool {
        return accessToken != nil
    }
    
    private var accessToken: String? {
        return UserDefaults.standard.string(forKey: "access_token")
    }
    
    private var refreshToken: String? {
        return UserDefaults.standard.string(forKey: "refresh_token")
    }
    
    private var expirationDate: Date? {
        return UserDefaults.standard.object(forKey: "expiration_date") as? Date
    }
    
    private var shouldRefreshToken: Bool {
        guard let expirationDate = expirationDate else {
            return false
        }
        let currentDate = Date()
        return currentDate.addingTimeInterval(5 * 60) >= expirationDate
    }
    
    public func exchangeCodeForToken(_ code: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: tokenApiURL) else {
            completion(false)
            return
        }
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: redirectURI)
        ]
        
        var request = URLRequest(url: url)
        let basicToken = "\(Keys.clientId):\(Keys.clientSecret)"
        let tokenData = basicToken.data(using: .utf8)
        guard let base64Str = tokenData?.base64EncodedString() else {
            completion(false)
            return
        }
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic \(base64Str)", forHTTPHeaderField: "Authorization")
        request.httpBody = components.query?.data(using: .utf8)
        
        makeTokenRequest(request: request) { [weak self] responseData in
            guard let tokens = responseData else {
                completion(false)
                return
            }
            self?.saveToken(tokens)
            completion(true)
        }
    }
    
    /// Supplies valid token will be used with Api calls
    public func withValidToken(completion: @escaping (String) -> Void) {
        guard !isRefreshing else {
            onResreshBlocks.append(completion)
            return
        }
        
        if shouldRefreshToken {
            refreshAccessToken { [weak self] isSuccess in
                if isSuccess, let token = self?.accessToken {
                    completion(token)
                }
            }
        } else if let token = accessToken {
            completion(token)
        }
    }
    
    public func refreshAccessToken(completion: ((Bool) -> Void)?) {
        guard shouldRefreshToken, !isRefreshing else {
            if !isRefreshing {
                completion?(true)
            }
            return
        }
        guard let refreshToken = refreshToken,
              let url = URL(string: tokenApiURL)
        else {
            completion?(false)
            return
        }
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "refresh_token", value: refreshToken)
        ]
        
        var request = URLRequest(url: url)
        let basicToken = "\(Keys.clientId):\(Keys.clientSecret)"
        let tokenData = basicToken.data(using: .utf8)
        guard let base64Str = tokenData?.base64EncodedString() else {
            completion?(false)
            return
        }
        isRefreshing = true
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic \(base64Str)", forHTTPHeaderField: "Authorization")
        request.httpBody = components.query?.data(using: .utf8)
        
        makeTokenRequest(request: request) { [weak self] responseData in
            guard let tokens = responseData else {
                completion?(false)
                return
            }
            self?.saveToken(tokens)
        }
    }
    
    public func saveToken(_ result: AuthResponse){
        if let refresh_token = result.refresh_token {
            UserDefaults.standard.set(refresh_token, forKey: "refresh_token")
        }
        UserDefaults.standard.set(result.access_token, forKey: "access_token")
        UserDefaults.standard.set(Date().addingTimeInterval(TimeInterval(result.expires_in)),
                                  forKey: "expiration_date")
    }
    
    public func signOut(completion: (Bool) -> Void) {
        UserDefaults.standard.setValue(nil, forKey: "refresh_token")
        UserDefaults.standard.setValue(nil, forKey: "access_token")
        UserDefaults.standard.setValue(nil, forKey: "expiration_date")
        completion(true)
    }
    
    // MARK: Private
    
    private func makeTokenRequest(request: URLRequest, completion: ((AuthResponse?) -> Void)?) {
        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            self?.isRefreshing = false
            guard let data = data,
                  error == nil
            else {
                completion?(nil)
                return
            }
            do {
                let jsonDecoder = JSONDecoder()
                let result = try jsonDecoder.decode(AuthResponse.self, from: data)
                completion?(result)
            } catch let error {
                print(error)
                completion?(nil)
            }
        }.resume()
    }
    
}
