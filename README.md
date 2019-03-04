
[![Build Status](https://travis-ci.org/Unicore/Unicore.svg?branch=master)](https://travis-ci.org/Unicore/Unicore)
[![Cocoapods](https://img.shields.io/cocoapods/v/Unicore.svg?style=flat)](https://cocoapods.org/pods/Unicore)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/Unicore.svg?style=flat)](https://cocoapods.org/pods/Unicore)
[![Platform](https://img.shields.io/cocoapods/p/Unicore.svg?style=flat)](https://cocoapods.org/pods/Unicore)

<img src="Docs/img/unicore-logo-light.svg" alt="Unicore" height="30"> The Unicore
======================================
[Architecture](#design-approach) | [Installation](#installation) | [Framework API](#api-and-usage) | [FAQ](#faq) | [Examples](#examples) | [Credits](#credits)

iOS: 9.0 + | macOS: 10.10 + | watchOS 2.0 + | tvOS: 9.0 +
___


The Unicore is a highly scalable **application design approach** (architecture) which lets you increase the maintainability of an application, increase testability, and give your team the flexibility by decoupling code of an application. 

It is a convenient combination of the **data-driven** and a **unidirectional dataflow**. 



The framework itself provides you the convenient way to manage the `State`. It's based on [Redux JS](https://redux.js.org/) ideas.


# Design Approach

The idea behind the Unicore is to have one *single source of truth* (app state) and make changes in a *unidirectional* manner.

![Unicore](Docs/img/unicore-minimal.png)

## App State

The app state would be that source it's a plain structure. For example simple structure like this:

```swift
struct AppState {
    let counter: Int
    let step: Int

    // Initial state
    static let initial = AppState(counter: 0, step: 1)
}
```
Let's imagine a simple app where we need to show the counter and increase/decrease buttons. And to add a bit of logic let's also have the control on a step.

So, in that case, the `AppState` would be our only source of the current app state, we look into the instance of the `AppState`  and we have the right values we need to display.
That's what is **single source of truth**.

But the problem here would be to give access to that state for each part of the app, screens, services, etc. and more importantly provide them with a way to mutate this state, so everybody knows that it was changed. The `Observer` pattern would solve these problems, but to make changes, we need some external ways not only internal as they usually are in the observer.

That's why we use the `Event Bus` pattern to solve this, and we dispatch actions to the [Core](#core) which would mutate the state.


## Core

`Core` is a dispatcher of the action, it uses the serial queue beneath so only one action gets handled at once that is why it is so important to not block a reducer function. `Core` is a generic type, so we can create it for any state we want.

```swift
let core = Core<AppState>( // #1
    state: AppState.initial, // #2
    reducer: reduce // #3
)
```
1. Set the generic parameter to `AppState` to let `Core` knows that we need a reducer which deals with `AppState` as a state.
2. Providing `Core` with the initial state
3. Providing core with the reducer, the function we have written before.

When you dispatch an action to the core, it uses a [Reducer](#reducer) to create a new version of the app state and then lets every subscriber know that there is a new app state.


## Actions

Actions are also plain structures conforming to `Action` protocol.

The name of the action describes what has happened, and fields of the action (payload) describe the details of the event. For example this action:
```swift
struct StepChangeRequested: Action {
    let step: Int
}
```
means that step change was requested and the new step requested to be equal to field `step`.

Some actions might contain no fields and the only information they bring is the name of the action.
```swift
struct CounterIncreaseRequested: Action {}
struct CounterDecreaseRequested: Action {}

```

These actions give us information that an increase or decrease of the counter was requested.

Having current state and action we can get the new state using `Reducer`.

## Reducer
A Reducer is a function which gets a state and action as a parameter and returns a new state, it's a pure function, and it must not block a current thread, that means every heavy calculation must be not in reducers.

And reducers are the only way to change the current state, for example, let's change the step if the action is `StepChangeRequested` then we update the step with the payload value:

```swift
func reduce(_ old: AppState, with action: Action) -> AppState {
    switch action {

    case let payload as StepChangeRequested: // #1
        return AppState( // # 2
            counter: old.counter, // #3
            step: payload.step // #4
        )

    default:
        return old // #5
    }
}
```
1. Unwrap `payload` if action is `StepChangeRequested`
2. Return new instance of `AppState`
3. `counter` value stays the same
4. `step` updates with the new value from `payload`
5. for all other actions returns the old state

Test of this reducer might be something like this:
```swift
func testReducer_StepChangeRequestedAction_stepMustBeUpdated() {
    let sut = AppState(counter: 0, step: 1)
    let action = StepChangeRequested(step: 7)
    let new = reduce(sut, with: action)
    XCTAssertEqual(new.step, 7)
}
```

Let's also add handlers for an increase and decrease actions:

```swift
func reduce(_ old: AppState, with action: Action) -> AppState {
    switch action {

    case let payload as StepChangeRequested:
        return AppState(
            counter: old.counter,
            step: payload.step
        )

    case is CounterIncreaseRequested:
        return AppState(
            counter: old.counter + old.step, // #1
            step: old.step
        )

    case is CounterDecreaseRequested:
        return AppState(
            counter: old.counter - old.step,
            step: old.step
        )

    default:
        return old
    }
}
```

1. We calculate a new value for `counter`

And tests would look something like this:

```swift
func testReducer_CounterIncreaseRequested_counterMustBeIncreased() {
    let sut = AppState(counter: 0, step: 3)
    let action = CounterIncreaseRequested()
    let new = reduce(sut, with: action)
    XCTAssertEqual(new.counter, 3)
}

func testReducer_CounterDecreaseRequested_counterMustBeDecreased() {
    let sut = AppState(counter: 0, step: 3)
    let action = CounterDecreaseRequested()
    let new = reduce(sut, with: action)
    XCTAssertEqual(new.counter, -3)
}
```

Alright, we prepare everything we need for making the application working, the only thing needed is to create our `Core` instance:


# Installation

Unicore is available through [CocoaPods](https://cocoapods.org) and [Carthage](https://github.com/Carthage/Carthage). To install
it, simply add

## Cocoapods
the following line to your Podfile:
```ruby
pod 'Unicore', '~> 1.0.2'
```

## Carthage 
or the following line to your Cartfile:
```sh
github "Unicore/Unicore"
```



# API and Usage

## Create Core

To use Unicore you have to create a `Core` class instance.
Since `Core` is a generic type, before that you have to define `State` class, it might be of any type you want. Let's say we have our state described as a structure [App State](#app-state), then you need to describe how this state is going to react to actions using a [Reducer](#reducer), now you good to go and you can create an instance of the `Core`:
```swift
let core = Core<AppState>(state: AppState.initial, reducer: reducer)
```

## Subscribe

The only way to get the current state is to subscribe to the state changes, **it's very important to know that you'll receive the current state value immediately when you subscribe**:

```swift
core.observe { state in
    // do something with state
    print(state.counter)
}.dispose(on: disposer) // dispose the subscription when current disposer will dispose
```

The closure will be called whenever the state updates.

If you want to handle state updates on a particular thread, e.g. main thread to update your screen, you can use
`observe(on: DispatchQueue)` syntax:

```swift
core.observe(on: .main) { (state) in
    self.counterLabel.text = String(state.counter)
}.dispose(on: disposer)
```

## Dispatch


```swift
let action = CounterIncreaseRequested() // #1
core.dispatch(action) // #2
```

## Dispose

When you subscribe to the state changes, the function `observe` returns a `PlainCommand` to remove the subscription when it's no longer needed. You can call it directly when you want to unsubscribe:
```swift
class YourClass {
    let unsubscribe: PlainCommand?

    func connect(to core: Core<AppState>) {
        unsubscribe = core.observe { (state) in
            // handle the state
        }
    }

    deinit {
        unsubscribe?()
    }
}
```

Or you can use a `Disposer` and add this command to it. A disposer will call this command when it will dispose:

```swift
class YourClass {
    let disposer = Disposer()

    func connect(to core: Core<AppState>) {
        core.observe { (state) in
            // handle the state
        }.dispose(on: disposer)
        // when YourClass will deinit hence disposer will also deinited, and before that, it will call all unsubscription functions registered in it
    }
}
```

### Dispatching
when you want the command to be executed only on a particular thread (queue), you can also set this by using `async(on:)` syntax

```swift
let printSevenOnMain = printSeven.async(on: .main)
```

now wherever you execute this command, it will be executed on the main thread.

# Examples

[TheMovieDB.org Client](https://github.com/MaximBazarov/TheMovieDB-Unicore) (Work In Progress)

# Credits

[Maxim Bazarov](https://github.com/MaximBazarov): A maintainer of the framework, and an evangelist of this approach.

[Alexey Demedetskiy](https://github.com/AlexeyDemedetskiy): An author of the original swift version and number of examples.

[Redux JS](https://redux.js.org/): The original idea.

# License
Unicore is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
