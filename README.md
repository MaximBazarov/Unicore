
[![Build Status](https://travis-ci.org/Unicore/Unicore.svg?branch=master)](https://travis-ci.org/Unicore/Unicore)
[![Version](https://img.shields.io/cocoapods/v/Unicore.svg?style=flat)](https://cocoapods.org/pods/Unicore)
[![License](https://img.shields.io/cocoapods/l/Unicore.svg?style=flat)](https://cocoapods.org/pods/Unicore)
[![Platform](https://img.shields.io/cocoapods/p/Unicore.svg?style=flat)](https://cocoapods.org/pods/Unicore)

<img src="Docs/img/unicore-logo-light.svg" alt="Unicore" height="30"> The Unicore
======================================
The Unicore is an application design approach which lets you increase the reliability of an application, increase testability, and give your team the flexibility by decoupling code of an application. It is a convenient combination of the data-driven and redux.js ideas. 

The framework itself provides you with a convenient way to apply this approach to your app.

- [The Unicore](#the-unicore)
  - [App State](#app-state)
  - [Core](#core)  
  - [Actions](#actions)
  - [Reducer](#reducer)  
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](https://github.com/Unicore/TheMovieDB)
- [Credits](#credits)
- [License](#license)

## The Unicore

The idea behind the Unicore is to have one *single source of truth* (app state) and make changes in a *unidirectional* manner.

## App State

The app state is a plain structure which conforms to `Codable` protocol. For example simple structure like this:

```swift
struct AppState: Codable {
    let counter: Int
    let step: Int
}
```

## Core

## Actions

## Reducer


![Unicore](https://raw.githubusercontent.com/MaximBazarov/Unicore/master/Docs/img/unicore-base.png)


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
