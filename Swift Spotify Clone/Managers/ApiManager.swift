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
        case failedToGetData, failedToGetPostParameters
    }
    
    typealias TypedCompletion<T> = (Result<T, Error>) -> Void
    
    typealias StatusCompletion = (Bool) -> Void
    
    public static let shared = ApiManager()
    
    private struct Constants {
        static let baseApiURL = "https://api.spotify.com/v1"
    }
    
    private init() {}
    
    // MARK: Public Methods
    
    // MARK: Profile
    
    public func getCurrentUserProfile(completion: @escaping TypedCompletion<UserProfile>) {
        performApiCall(to: Constants.baseApiURL + "/me",
                       method: .GET,
                       returnModel: UserProfile.self,
                       completion: completion,
                       postParameters: nil)
    }
    
    // MARK: Browse Screen
    
    public func getNewReleases(completion: @escaping TypedCompletion<NewReleasesResponse>) {
        performApiCall(to: Constants.baseApiURL + "/browse/new-releases?limit=50",
                       method: .GET,
                       returnModel: NewReleasesResponse.self,
                       completion: completion,
                       postParameters: nil)
    }
    
    public func getFeaturedPlaylists(completion: @escaping TypedCompletion<FeaturedPlaylistsResponse>) {
        performApiCall(to: Constants.baseApiURL + "/browse/featured-playlists?limit=50",
                       method: .GET,
                       returnModel: FeaturedPlaylistsResponse.self,
                       completion: completion,
                       postParameters: nil)
    }
    
    public func getRecommendations(genres: Set<String>, completion: @escaping TypedCompletion<RecommendationsResponse>) {
        let seeds = genres.joined(separator: ",")
        performApiCall(to: Constants.baseApiURL + "/recommendations?limit=50&seed_genres=\(seeds)",
                       method: .GET,
                       returnModel: RecommendationsResponse.self,
                       completion: completion,
                       postParameters: nil)
    }
    
    public func getRecommendedGenres(completion: @escaping TypedCompletion<RecommendedGenresResponse>) {
        performApiCall(to: Constants.baseApiURL + "/recommendations/available-genre-seeds",
                       method: .GET,
                       returnModel: RecommendedGenresResponse.self,
                       completion: completion,
                       postParameters: nil)
    }
    
    // MARK: Album
    
    public func getAlbumDetails(for album: Album, completion: @escaping TypedCompletion<AlbumDetailsResponse>) {
        performApiCall(to: Constants.baseApiURL + "/albums/" + album.id,
                       method: .GET,
                       returnModel: AlbumDetailsResponse.self,
                       completion: completion,
                       postParameters: nil)
    }
    
    // MARK: Playlists
    
    public func getPlaylistDetails(for playlist: Playlist, completion: @escaping TypedCompletion<PlaylistDetailsResponse>) {
        performApiCall(to: Constants.baseApiURL + "/playlists/" + playlist.id,
                       method: .GET,
                       returnModel: PlaylistDetailsResponse.self,
                       completion: completion,
                       postParameters: nil)
    }
    
    public func getCurrentUserPlaylists(completion: @escaping TypedCompletion<PlaylistResponse>) {
        performApiCall(
            to: Constants.baseApiURL + "/me/playlists?limit=50",
            method: .GET,
            returnModel: PlaylistResponse.self,
            completion: completion,
            postParameters: nil)
    }
    
    public func createPlaylist(with name: String, completion: @escaping TypedCompletion<Playlist>) {
        getCurrentUserProfile { [weak self] result in
            switch result {
            case .success(let model):
                self?.performApiCall(
                    to: Constants.baseApiURL + "/users/\(model.id)/playlists",
                    method: .POST,
                    returnModel: Playlist.self,
                    completion: completion,
                    postParameters: ["name": name])
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func addTrackToPlaylist(track: AudioTrack, playlist: Playlist, completion: @escaping StatusCompletion) {
        performApiCall(to: Constants.baseApiURL + "/playlists/\(playlist.id)/tracks",
                       postParameters: [
                        "uris": [
                            "spotify:track:\(track.id)"
                        ]
                       ],
                       completion: completion,
                       keyParameter: "snapshot_id")
    }
    
    public func removeTrackFromPlaylist(track: AudioTrack, playlist: Playlist, completion: @escaping StatusCompletion) {
        
    }
    
    // MARK: Category
    
    public func getCategories(completion: @escaping TypedCompletion<AllCategoriesResponse>) {
        performApiCall(
            to: Constants.baseApiURL + "/browse/categories?limit=50",
            method: .GET,
            returnModel: AllCategoriesResponse.self,
            completion: completion,
            postParameters: nil)
    }
    
    public func getCategoryPlaylists(for categoryId: String, completion: @escaping TypedCompletion<CategoryPlaylistsResponse>) {
        performApiCall(
            to: Constants.baseApiURL + "/browse/categories/\(categoryId)/playlists?limit=50",
            method: .GET,
            returnModel: CategoryPlaylistsResponse.self,
            completion: completion,
            postParameters: nil)
    }
    
    // MARK: Search
    
    public func search(with query: String, completion: @escaping TypedCompletion<SearchResultsResponse>) {
        let urlPath = Constants.baseApiURL + "/search?limit=15&type=album,artist,playlist,track" +
        "&q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        performApiCall(
            to: urlPath,
            method: .GET,
            returnModel: SearchResultsResponse.self,
            completion: completion,
            postParameters: nil)
    }
    
    public func getTypedSearchResults(query: String, completion: @escaping TypedCompletion<[SearchResult]>) {
        self.search(with: query) { result in
            switch result {case .success(let model):
                var searchResults = [SearchResult]()
                searchResults.append(contentsOf: model.tracks.items.compactMap({ SearchResult.track(model: $0) }))
                searchResults.append(contentsOf: model.albums.items.compactMap({ SearchResult.album(model: $0) }))
                searchResults.append(contentsOf: model.artists.items.compactMap({ SearchResult.artist(model: $0) }))
                searchResults.append(contentsOf: model.playlists.items.compactMap({ SearchResult.playlist(model: $0) }))
                completion(.success(searchResults))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: Private Methods
    
    private func performApiCall<T: Codable>(to urlString: String, method: HTTPMethod, returnModel: T.Type, completion: @escaping TypedCompletion<T>, postParameters: [String: String]?) {
        createRequest(URL(string: urlString),
                      type: method) { [weak self] baseRequest in
            var request = baseRequest
            switch method {
            case .GET:
                break
            case .POST:
                guard let body = postParameters else {
                    completion(.failure(ApiError.failedToGetPostParameters))
                    return
                }
                request.httpBody = try? JSONSerialization.data(withJSONObject: body,
                                                               options: .fragmentsAllowed)
            }
            self?.returnTypedResponse(T.self,
                                      request: request,
                                      completion: completion)
        }
    }
    
    private func performApiCall(to urlString: String, postParameters: [String: Any], completion: @escaping StatusCompletion, keyParameter: String?) {
        createRequest(URL(string: urlString),
                      type: .POST) { baseRequest in
            guard let body = try? JSONSerialization.data(withJSONObject: postParameters,
                                                         options: .fragmentsAllowed)
            else {
                completion(false)
                return
            }
            var request = baseRequest
            request.httpBody = body
            request.setValue("application/json",
                             forHTTPHeaderField: "Content-Type")
            URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data,
                        error == nil
                else {
                    print(String(describing: error))
                    completion(false)
                    return
                }
                if let keyParameter = keyParameter {
                    do {
                        let result = try JSONSerialization.jsonObject(with: data,
                                                                            options: .fragmentsAllowed)
                        guard let json = result as? [String: Any],
                              let _ = json[keyParameter] as? String
                        else {
                            completion(false)
                            return
                        }
                    } catch let error {
                        completion(false)
                        print(error)
                        return
                    }
                } else {
                    completion(true)
                }
            }.resume()
        }
    }
    
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
    
    private func returnTypedResponse<T: Codable>(_ type: T.Type, request: URLRequest, completion: @escaping TypedCompletion<T>) {
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(ApiError.failedToGetData))
                print("Cannot get data")
                return
            }
            
            do {
                let result = try JSONDecoder().decode(type,
                                                      from: data)
                completion(.success(result))
            } catch let error {
                completion(.failure(error))
                print(error)
            }
        }.resume()
    }
    
    /// Test Get Api Call
    private func callApiToPrintResponse(_ urlString:String) {
        createRequest(URL(string: urlString),
                      type: .GET) { request in
            URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    print("Cannot get data")
                    return
                }
                
                do {
                    let result = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                    print(result)
                } catch let error {
                    print(error)
                }
            }.resume()
        }
    }
}
