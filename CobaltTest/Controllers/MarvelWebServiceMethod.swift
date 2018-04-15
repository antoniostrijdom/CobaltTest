//
//  MarvelWebServiceMethod.swift
//  CobaltTest
//
//  Created by Antonio Strijdom on 14/04/2018.
//  Copyright © 2018 Antonio Strijdom. All rights reserved.
//

import Foundation
import CryptoSwift

// public key
fileprivate let kMarvelWebServicePrivateKey = "((Insert private key here))"
// private key
fileprivate let kMarvelWebServicePublicKey = "((Insert public key here))"

// MARK: - Protocol

/// protocol that defines Marvel web method calls
protocol MarvelWebServiceMethod: WebServiceMethod {
    
}

extension MarvelWebServiceMethod {
    var httpHeaders: [(String, String)]? {
        get {
            return nil
        }
    }
    var defaultParameters: [URLQueryItem]? {
        get {
            // add the required timestamp and hash parameters
            
            // generate timestamp
            let formatter = DateFormatter()
            formatter.dateFormat = "hhmmss"
            let timeStamp = formatter.string(from: Date())
            
            // generate hash
            let hash = "\(timeStamp)\(kMarvelWebServicePrivateKey)\(kMarvelWebServicePublicKey)".md5()
            
            // create query items
            let apiKeyItem = URLQueryItem(name: "apikey", value: kMarvelWebServicePublicKey)
            let tsQueryItem = URLQueryItem(name: "ts", value: timeStamp)
            let hashItem = URLQueryItem(name: "hash", value: hash)
            
            return [apiKeyItem, tsQueryItem, hashItem]
        }
    }
}
