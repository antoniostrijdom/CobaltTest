//
//  Characters.swift
//  CobaltTest
//
//  Created by Antonio Strijdom on 12/04/2018.
//  Copyright © 2018 Antonio Strijdom. All rights reserved.
//

import Foundation

// MARK: - Protocol

/// Web method for GETing a list of characters from the Marvel web service
public struct CharactersWebMethod: MarvelWebServiceMethod {
    
    // MARK: - DTO
    
    public struct CharacterDataWrapper: Decodable {
        var code: Int? = nil
        var data: CharacterDataContainer? = nil
    }
    
    public struct CharacterDataContainer: Decodable {
        var results: [Character]? = nil
    }
    
    public struct Character: Decodable {
        var name: String? = nil
        var description: String? = nil
        var thumbnail: Image? = nil
    }
    
    public struct Image: Decodable {
        var path: String? = nil
        var ext: String? = nil
        
        enum CodingKeys: String, CodingKey {
            case path
            case ext = "extension"
        }
    }
    
    typealias Response = CharacterDataWrapper
    var requestURL: URL = URL(string: "https://gateway.marvel.com/v1/public/characters")!
    
    /// Get a list of characters from the Marvel web service
    /// - Parameters:
    ///   - limit: The maximum number of characters to retreive
    ///   - completeBlock: The block that is executed when the web service returns
    func getCharacters(withLimit limit: Int?,
                       complete completeBlock: @escaping (CharacterDataWrapper?, Error?) -> Void) {
        DispatchQueue.global().async {
            do {
                var params: [URLQueryItem]? = nil
                if let limitParam = limit {
                    params = [URLQueryItem(name: "limit", value: "\(limitParam)")]
                }
                let result = try self.sendRequestSync(parameters: params)
                DispatchQueue.main.async {
                    completeBlock(result.1, nil)
                }
            } catch let error {
                DispatchQueue.main.async {
                    completeBlock(nil, error)
                }
            }
        }
    }
}
