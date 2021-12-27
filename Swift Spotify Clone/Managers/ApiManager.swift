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
    
    // MARK: Public Methods
    
    // MARK: Profile
    
    public func getCurrentUserProfile(completion: @escaping TypedCompletion<UserProfile>) {
        performApiCall(to: Constants.baseApiURL + "/me",
                       method: .GET,
                       returnModel: UserProfile.self,
                       completion: completion)
    }
    
    // MARK: Browse Screen
    
    public func getNewReleases(completion: @escaping TypedCompletion<NewReleasesResponse>) {
        performApiCall(to: Constants.baseApiURL + "/browse/new-releases?limit=50",
                       method: .GET,
                       returnModel: NewReleasesResponse.self,
                       completion: completion)
    }
    
    public func getFeaturedPlaylists(completion: @escaping TypedCompletion<FeaturedPlaylistsResponse>) {
        performApiCall(to: Constants.baseApiURL + "/browse/featured-playlists?limit=50",
                       method: .GET,
                       returnModel: FeaturedPlaylistsResponse.self,
                       completion: completion)
    }
    
    public func getRecommendations(genres: Set<String>, completion: @escaping TypedCompletion<RecommendationsResponse>) {
        let seeds = genres.joined(separator: ",")
        performApiCall(to: Constants.baseApiURL + "/recommendations?limit=50&seed_genres=\(seeds)",
                       method: .GET,
                       returnModel: RecommendationsResponse.self,
                       completion: completion)
    }
    
    public func getRecommendedGenres(completion: @escaping TypedCompletion<RecommendedGenresResponse>) {
        performApiCall(to: Constants.baseApiURL + "/recommendations/available-genre-seeds",
                       method: .GET,
                       returnModel: RecommendedGenresResponse.self,
                       completion: completion)
    }
    
    // MARK: Album
    
    public func getAlbumDetails(for album: Album, completion: @escaping TypedCompletion<AlbumDetailsResponse>) {
        performApiCall(to: Constants.baseApiURL + "/albums/" + album.id,
                       method: .GET,
                       returnModel: AlbumDetailsResponse.self,
                       completion: completion)
    }
    
    // MARK: Playlists
    
    public func getPlaylistDetails(for playlist: Playlist, completion: @escaping TypedCompletion<PlaylistDetailsResponse>) {
        performApiCall(to: Constants.baseApiURL + "/playlists/" + playlist.id,
                       method: .GET,
                       returnModel: PlaylistDetailsResponse.self,
                       completion: completion)
    }
    
    // MARK: Category
    
    public func getCategories(completion: @escaping TypedCompletion<AllCategoriesResponse>) {
        performApiCall(
            to: Constants.baseApiURL + "/browse/categories?limit=50",
            method: .GET,
            returnModel: AllCategoriesResponse.self,
            completion: completion)
    }
    
    public func getCategoryPlaylists(for categoryId: String, completion: @escaping TypedCompletion<CategoryPlaylistsResponse>) {
        performApiCall(
            to: Constants.baseApiURL + "/browse/categories/\(categoryId)/playlists?limit=50",
            method: .GET,
            returnModel: CategoryPlaylistsResponse.self,
            completion: completion)
    }
    
    // MARK: Search
    
    public func search(with query: String, completion: @escaping TypedCompletion<SearchResultsResponse>) {
        let urlPath = Constants.baseApiURL + "/search?limit=15&type=album,artist,playlist,track" +
            "&q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        performApiCall(
            to: urlPath,
            method: .GET,
            returnModel: SearchResultsResponse.self,
            completion: completion)
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
    
    private func performApiCall<T: Codable>(to urlString: String, method: HTTPMethod, returnModel: T.Type, completion: @escaping TypedCompletion<T>) {
        createRequest(URL(string: urlString),
                      type: .GET) { [weak self] request in
            self?.returnTypedResponse(T.self,
                                      request: request,
                                      completion: completion)
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
