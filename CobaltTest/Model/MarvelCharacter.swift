//
//  Character.swift
//  CobaltTest
//
//  Created by Antonio Strijdom on 15/04/2018.
//  Copyright © 2018 Antonio Strijdom. All rights reserved.
//

import Foundation
import UIKit

public struct MarvelCharacter {
    // MARK: - Properties
    
    let name: String
    let description: String
    let thumbnailURL: URL?
    
    // MARK: - Init
    
    /// Memberwise initialiser
    init(name: String, description: String, thumbnailURL: URL?) {
        self.name = name
        self.description = description
        self.thumbnailURL = thumbnailURL
    }
    
    // MARK: - Methods
    
    /// Transforms a CharactersWebMethod into an array of Characters
    /// - Parameters:
    ///   - result: The result of the CharactersWebMethod call
    /// - Returns: An array of Character structs or nil
    static func CharactersFromWebMethodResult(result: CharactersWebMethod.CharacterDataWrapper?) -> [MarvelCharacter]? {
        guard let dataWrapper = result else {
            return nil
        }
        guard let characters = dataWrapper.data?.results else {
            return []
        }
        return characters.map({ (character) -> MarvelCharacter in
            var thumbURL: URL? = nil
            if let thumbPath = character.thumbnail?.path {
                if let thumbExt = character.thumbnail?.ext {
                    thumbURL = URL(string: "\(thumbPath).\(thumbExt)")
                } else {
                    thumbURL = URL(string: thumbPath)
                }
            }
            return MarvelCharacter(name: character.name ?? "",
                             description: character.description ?? "",
                             thumbnailURL: thumbURL)
        })
    }
    
    /// Asynchronously loads the thumbnail image if there is one
    /// - Parameters:
    ///   - complete: Closure called when the image is loaded
    func thumbImage(_ complete: @escaping (UIImage) -> Void) {
        guard nil != thumbnailURL else { return }
        DispatchQueue.global().async {
            // protected by guard above
            if let imageData = try? Data(contentsOf: self.thumbnailURL!) {
                if let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        complete(image)
                    }
                }
            }
        }
    }
}
