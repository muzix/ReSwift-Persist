//
//  PersistStore.swift
//  ReSwift-Persist
//
//  Created by muzix on 9/8/19.
//  Copyright © 2019 muzix. All rights reserved.
//

import ReSwift

public class PersistStore<State: PersistState>: Store<State> {
    public convenience init(config: PersistConfig,
                            reducer: @escaping Reducer<State>,
                            state: State?,
                            middleware: [Middleware<State>] = [],
                            automaticallySkipsRepeats: Bool = true) {
        self.init(reducer: persistReducer(config: config, baseReducer: reducer),
                  state: state,
                  middleware: middleware,
                  automaticallySkipsRepeats: automaticallySkipsRepeats)
    }

    required init(reducer: @escaping Reducer<State>,
                  state: State?,
                  middleware: [Middleware<State>] = [],
                  automaticallySkipsRepeats: Bool = true) {
        super.init(reducer: reducer,
                   state: state,
                   middleware: middleware,
                   automaticallySkipsRepeats: automaticallySkipsRepeats)
    }
}
