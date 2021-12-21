//
//  ApiManager.swift
//  Swift Spotify Clone
//
//  Created by Олег Ефимов on 20.12.2021.
//

import Foundation

final class ApiManager {
    
    enum HTTPMethod: String {
        case GET, POST
    }
    
    enum ApiError: Error {
        case failedToGetData
    }
    
    typealias TypedCompletion<T> = (Result<T, Error>) -> Void
    
    public static let shared = ApiManager()
    
    private struct Constants {
        static let baseApiURL = "https://api.spotify.com/v1"
    }
    
    private init() {}
    
    public func getCurrentUserProfile(completion: @escaping TypedCompletion<UserProfile>) {
        createRequest(URL(string: "\(Constants.baseApiURL)/me"),
                     type: .GET) { request in
            URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(UserProfile.self, from: data)
                    completion(.success(result))
                } catch let error {
                    completion(.failure(error))
                }
            }.resume()
       }
    }
    
    // MARK: Private
    
    private func createRequest(_ url: URL?, type: HTTPMethod, completion: @escaping (URLRequest) -> Void) {
        AuthManager.shared.withValidToken { token in
            guard let url = url else {
                return
            }
            var request = URLRequest(url: url)
            request.setValue("Bearer \(token)",
                             forHTTPHeaderField: "Authorization")
            request.httpMethod = type.rawValue
            request.timeoutInterval = 30
            completion(request)
        }
    }
}
