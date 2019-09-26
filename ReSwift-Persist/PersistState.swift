//
//  Types.swift
//  ReSwift-Persist
//
//  Created by muzix on 9/8/19.
//  Copyright © 2019 muzix. All rights reserved.
//

import ReSwift

public typealias PersistState = StateType & Codable & Equatable & PersistableState

public protocol PersistableState {
    /// - Parameter state: The last state
    /// - Returns: Return true to skip state persisting
    func shouldSkipPersist(_ state: Self) -> Bool
}

public extension PersistableState where Self: Equatable {
    func shouldSkipPersist(_ state: Self) -> Bool {
        return self == state
    }
}

public protocol AnyMigratable {
    func _migrate(filePath: URL) throws -> Any //swiftlint:disable:this identifier_name
}

public protocol Migratable: AnyMigratable {
    associatedtype NewState: PersistState
    func migrate(filePath: URL) throws -> NewState
}

public extension Migratable {
    func _migrate(filePath: URL) throws -> Any { //swiftlint:disable:this identifier_name
        return try migrate(filePath: filePath)
    }
}
