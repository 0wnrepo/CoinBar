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
    case noValidJSONResponseError(String?)
}

public typealias completion = ((Result<[String: Any]>) -> Void)

private let baseUrlString = "https://coincap.io"

public struct NetworkHandler {
    public static let shared = NetworkHandler()
    
    private init() {}
    
    private func get(url: URL, completion: @escaping completion) {
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
                } else {
                    // no valid json result
                    guard let json = data.decoded() else {
                        completion(.error(Errors.noValidJSONResponseError(String(data: data, encoding: .utf8))))
                        return
                    }
                    completion(.success(json))
                }
            }
            }.resume()
    }
}

// MARK: Coin Overview data
extension NetworkHandler {
    public func getCoinData(identifier: String, completion: @escaping completion) {
        let urlString = baseUrlString + "/page/" + identifier
        guard let url = URL(string: urlString) else {
            completion(.error(Errors.noValidUrlStringError(urlString)))
            return
        }
        get(url: url, completion: completion)
    }
}


// MARK: Data converting into a dictionary directly
private extension Data {
    func decoded() -> [String: Any]? {
        var json: [String: Any]? = nil
        
        do {
            json = try JSONSerialization.jsonObject(with: self) as? [String: Any]
            guard let usd = json?["usdPrice"] as? String,
                let btc = json?["btcPrice"] as? Double,
                let perc = json?["perc"] as? String else {
                    return nil
            }
            
            json = [
                "usd": Double(usd)!,
                "btc": 1.0 / btc,
                "perc": Double(perc)!
            ]
            
        } catch (let error ) {
            print("Failed with json", error)
        }
        
        return json
    }
}
