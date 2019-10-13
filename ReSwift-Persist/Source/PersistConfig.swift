//
//  PersistConfig.swift
//  ReSwift-Persist
//
//  Created by muzix on 9/8/19.
//  Copyright © 2019 muzix. All rights reserved.
//

import Foundation

public struct PersistConfig {
    let persistDirectory: String
    let version: String
    let jsonDecoder: (() -> JSONDecoder)
    let jsonEncoder: (() -> JSONEncoder)
    var migration: [String: AnyMigratable]?
    public var debug = false

    public init(persistDirectory: String,
                version: String,
                jsonDecoder: (() -> JSONDecoder)? = nil,
                jsonEncoder: (() -> JSONEncoder)? = nil,
                migration: [String: AnyMigratable]? = nil) {
        self.persistDirectory = persistDirectory
        self.version = version
        self.jsonDecoder = jsonDecoder ?? {
            let defaultDecoder = JSONDecoder()
            defaultDecoder.dateDecodingStrategy = .secondsSince1970
            return defaultDecoder
        }
        self.jsonEncoder = jsonEncoder ?? {
            let defaultEncoder = JSONEncoder()
            defaultEncoder.dateEncodingStrategy = .secondsSince1970
            return defaultEncoder
        }
        self.migration = migration
    }

    func log(_ any: Any) {
        guard debug else { return }
        print("\(any)")
    }
}
