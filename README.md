# ReSwift-Persist

## Installation
```
pod 'ReSwift-Persist'
```

## Example

```swift
// App state should comforms PersistState
struct AppState: PersistState { }

// Initialize PersistStore
var config = PersistConfig(persistDirectory: "data", version: "1")
config.debug = true
let persistStore = PersistStore(config: config, reducer: appReducer, state: nil)

```

Please check Todo example for usage detail. 

## Credits

Inspired by [ReSwift](https://github.com/ReSwift/ReSwift) and [Redux-persist](https://github.com/rt2zz/redux-persist)

## License

Distributed under the MIT License (MIT).
