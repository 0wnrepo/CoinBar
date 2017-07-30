//
//  NetworkHandler.swift
//  CoinBar
//
//  Created by Benny Lach on 29.07.17.
//  Copyright © 2017 DevKiste. All rights reserved.
//

import Foundation

public enum Result<T> {
    case success(T)
    case error(Error)
}

private enum Errors: Error {
    case noValidUrlStringError(String)
    case noValidHTTPResponseError
    case wrongStatusCodeError(Data?)
    case failedFetchingDataError
    case noValidJSONResponseError(Data?)
}

public typealias completion<T> = ((Result<T>) -> Void)

private typealias dataCompletion = ((Result<Data>) -> Void )
private let baseUrlString = "https://coincap.io"

public struct NetworkHandler {
    public static let shared = NetworkHandler()
    
    private init() {}
    
    private func get(url: URL, completion: @escaping dataCompletion) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                // Finished with error
                if let _error = error {
                    completion(.error(_error))
                    return
                }
                // Response or data is nil
                guard let response = response as? HTTPURLResponse, let data = data else {
                    completion(.error(Errors.noValidHTTPResponseError))
                    return
                }
                // status code != 200
                if response.statusCode != 200 {
                    completion(.error(Errors.wrongStatusCodeError(data)))
                    return
                } else {
                    completion(.success(data))
                }
            }
            }.resume()
    }
}

// MARK: Coin Overview data
extension NetworkHandler {
    public func getCoinData(identifier: String, completion: @escaping completion<CoinObject>) {
        let urlString = baseUrlString + "/page/" + identifier
        guard let url = URL(string: urlString) else {
            completion(.error(Errors.noValidUrlStringError(urlString)))
            return
        }
        
        get(url: url) { (result) in
            switch result {
            case .error(let error):
                completion(.error(error))
            case .success(let data):
                if let object: CoinObject = self.decodeJSON(data: data) {
                    completion(.success(object))
                } else {
                    completion(.error(Errors.noValidJSONResponseError(data)))
                }
            }
        }
    }
    
    private func decodeJSON<T: Decodable>(data: Data) -> T? {
        let decoder = JSONDecoder()
        let decoded = try? decoder.decode(T.self, from: data)
        
        return decoded
    }
}
