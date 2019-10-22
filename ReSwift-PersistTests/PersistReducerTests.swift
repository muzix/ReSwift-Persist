//
//  PersistReducerTests.swift
//  ReSwift-PersistTests
//
//  Created by muzix on 9/8/19.
//  Copyright © 2019 muzix. All rights reserved.
//

import XCTest
import ReSwift
@testable import ReSwift_Persist

class PersistReducerTests: XCTestCase {

    struct Constants {
        static let persistFolder = "data"
        static let skipCounter = 9
    }

    struct SubState: PersistState {
        var subCounter: Int
    }

    struct AppState: PersistState {
        var counter: Int
        var subState: SubState

        init(counter: Int) {
            self.counter = counter
            self.subState = SubState(subCounter: 0)
        }

        func shouldSkipPersist(_ newState: AppState) -> Bool {
            return newState.counter == Constants.skipCounter &&
            subState.shouldSkipPersist(newState.subState)
        }
    }

    struct AppStateV1: PersistState {
        var counter: Int
    }

    struct MigrationFromV1: Migratable {
        func migrate(filePath: URL) throws -> AppState {
            let oldAppState = try? JSONDecoder().decode(AppState.self,
                                                        from: Data(contentsOf: filePath))
            return AppState(counter: oldAppState?.counter ?? 0)
        }
    }

    struct Mock {
        static func reducer(action: Action, state: AppState?) -> AppState {
            var state = state ?? AppState(counter: 0)
            switch action {
            case let changeCounter as ChangeCounter:
                state.counter = changeCounter.counter
            default:
                break
            }
            return state
        }
    }

    struct ChangeCounter: Action {
        let counter: Int
    }

    override func setUp() {
        super.setUp()
        clean()
    }

    override func tearDown() {
        clean()
        super.tearDown()
    }

    func test_persist_directory_initialization() {
        clean()
        initializeStore()
        let appStatePath = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
            )[0]
            .appendingPathComponent(Constants.persistFolder)
            .appendingPathComponent("AppState")
        let appStatePathExists = FileManager.default.fileExists(atPath: appStatePath.path)
        XCTAssertTrue(appStatePathExists)

        let versionPath = appStatePath.appendingPathComponent("version.json")
        let versionInfo = try? JSONDecoder().decode(VersionInfo.self,
                                               from: Data(contentsOf: versionPath))
        XCTAssertEqual(versionInfo?.current, "1")
        clean()
    }

    func test_data_persisted_successfully() {
        clean()
        let store = initializeStore()
        store.dispatch(ChangeCounter(counter: 10))
        let appStatePath = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
            )[0]
            .appendingPathComponent(Constants.persistFolder)
            .appendingPathComponent("AppState/1/AppState.json")
        let storedState = try? JSONDecoder().decode(AppState.self,
                                                    from: Data(contentsOf: appStatePath))
        XCTAssertEqual(storedState?.counter, 10)
        clean()
    }

    func test_skip_persist() {
        clean()
        let store = initializeStore()

        // Dispatch non-skip action
        store.dispatch(ChangeCounter(counter: 10))
        let appStatePath = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
            )[0]
            .appendingPathComponent(Constants.persistFolder)
            .appendingPathComponent("AppState/1/AppState.json")
        let storedState = try? JSONDecoder().decode(AppState.self,
                                                    from: Data(contentsOf: appStatePath))
        XCTAssertEqual(storedState?.counter, 10)

        // Dispatch skip action
        store.dispatch(ChangeCounter(counter: Constants.skipCounter))
        let newStoredState = try? JSONDecoder().decode(AppState.self,
                                                    from: Data(contentsOf: appStatePath))
        XCTAssertEqual(newStoredState?.counter, 10)

        clean()
    }

    func test_data_migration_successfully() {
        clean()
        initializeStore()

        // Save first version of data
        let store = initializeStore()
        store.dispatch(ChangeCounter(counter: 10))
        let appStatePath = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
            )[0]
            .appendingPathComponent(Constants.persistFolder)
            .appendingPathComponent("AppState/1/AppState.json")
        let storedState = try? JSONDecoder().decode(AppState.self,
                                                    from: Data(contentsOf: appStatePath))
        XCTAssertEqual(storedState?.counter, 10)

        // Migrate to new version
        var config = PersistConfig(persistDirectory: Constants.persistFolder,
                                   version: "2",
                                   migration: ["1": MigrationFromV1()])
        config.debug = true
        _ = PersistStore(config: config, reducer: Mock.reducer, state: nil)

        // Verify migration
        let appStateDirPath = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
            )[0]
            .appendingPathComponent(Constants.persistFolder)
            .appendingPathComponent("AppState")
        let versionPath = appStateDirPath.appendingPathComponent("version.json")
        let versionInfo = try? JSONDecoder().decode(VersionInfo.self,
                                                    from: Data(contentsOf: versionPath))
        XCTAssertEqual(versionInfo?.current, "2")

        let appStateV2Path = appStateDirPath.appendingPathComponent("2/AppState.json")
        let appStateV2 = try? JSONDecoder().decode(AppState.self,
                                                   from: Data(contentsOf: appStateV2Path))
        XCTAssertEqual(appStateV2?.counter, 10)

        clean()
    }

    @discardableResult private func initializeStore() -> PersistStore<AppState> {
        var persistConfig = PersistConfig(persistDirectory: Constants.persistFolder, version: "1")
        persistConfig.debug = true
        return PersistStore(config: persistConfig, reducer: Mock.reducer, state: nil)
    }

    private func clean() {
        let dataPath = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask)[0]
            .appendingPathComponent(Constants.persistFolder)
        try? FileManager.default.removeItem(atPath: dataPath.path)
    }
}
