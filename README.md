
[![Build Status](https://travis-ci.org/Unicore/Unicore.svg?branch=master)](https://travis-ci.org/Unicore/Unicore)
[![Version](https://img.shields.io/cocoapods/v/Unicore.svg?style=flat)](https://cocoapods.org/pods/Unicore)
[![License](https://img.shields.io/cocoapods/l/Unicore.svg?style=flat)](https://cocoapods.org/pods/Unicore)
[![Platform](https://img.shields.io/cocoapods/p/Unicore.svg?style=flat)](https://cocoapods.org/pods/Unicore)

<img src="Docs/img/unicore-logo-light.svg" alt="Unicore" height="30"> The Unicore
======================================
The Unicore is an application design approach which lets you increase the reliability of an application, increase testability, and give your team the flexibility by decoupling code of an application. It is a convenient combination of the data-driven and redux.js ideas. 

The framework itself provides you with a convenient way to apply this approach to your app.

- [Building Blocks](#building-blocks)
  - [App State](#app-state)
  - [Core](#core)  
  - [Actions](#actions)
  - [Reducer](#reducer)  
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](https://github.com/Unicore/TheMovieDB)
- [Credits](#credits)
- [License](#license)

## Building Blocks

The idea behind the Unicore is to have one *single source of truth* (app state) and make changes in a *unidirectional* manner.

### App State

The app state is a plain structure which conforms to `Codable` protocol. For example simple structure like this:

```swift
struct AppState: Codable {
    let counter: Int
    let step: Int
}
```

The only way to mutate the state id to send an **Action** describing what has happend

### Actions

Actions are also plain structures conforming to `Codable` protocol:

The name of the action describes what has happened, and fields of the action (payload) describe the details of the event. For example this action:
```swift
struct StepChangeRequested: Codable {
    let step: Int
}
```      
means that step change was requested and the new step requested to be equal to field `step`.

Some actions might contain no fields and the only information they bring is the name of the action.
```swift
struct CounterIncreaseRequested: Codable {}
```      

That action gives us information that an increase of the counter was requested and that is it.

Having current state and action we can get the new state using `Reducer`.

### Reducer



### Core


## Requirements

* iOS: 9.0 +
* macOS: 10.10 +
* watchOS 2.0 +
* tvOS: 9.0 +

## Installation

Unicore is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Unicore'
```

## Credits

[Maxim Bazarov](https://github.com/MaximBazarov):  Maintainer of the framework, and evangelist of this approach.

[Alexey Demedetskiy](https://github.com/AlexeyDemedetskiy): Author of the first version and number of examples.

[Redux JS](https://redux.js.org/): original idea.



## License

Unicore is available under the MIT license. See the LICENSE file for more info.
