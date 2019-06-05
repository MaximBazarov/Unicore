//
//  Core.swift
//  Unicore
//
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//


import Foundation
import Command


// MARK: - Protocols -


/// Action is a marker protocol.
/// It's better to know that you will receive an Action rather than Any
/// Also, it's easy to understand where the struct is marked as an Action
public protocol Action {}

// MARK: - Core -

/// The Core is the simple State manager.
/// There is no way to obtain the current state by accessing a Core's field.
/// The only way to get the state is to subscribe to the State's updates.
/// And the only way to mutate the State is to dispatch an Action.
///
/// After action got dispatched, the core will get the new instance of the State by calling the reducer with the current state and an action.
/// ```
/// state = reducer(state, action)
/// ```
/// And then the Core will notify all the subscribers with the new State.
public final class Core<State> {
    
    private let coreDispatchQueue = DispatchQueue(label: "com.unicore.core-lock-queue")
    
    private var state: State
    private let reducer: (State, Action) -> State
    private var actionsObservers: Set<CommandOf<(State, Action)>> = []
    private var stateObservers:  Set<CommandOf<State>> = []
    
    public init(state: State, reducer: @escaping (State, Action) -> State) {
        self.state = state
        self.reducer = reducer
    }
    
    /// The only way to mutate the State is to dispatch an Action.
    /// After action got dispatched, the core will get the new instance of the State by calling the reducer with the current state and an action.
    /// Then the Core will notify all the subscribers with the new State.
    ///
    /// - Parameter action: Action regarding which state must be mutated.
    public func dispatch(_ action: Action) {
        coreDispatchQueue.async {
            self.actionsObservers.forEach {$0.execute(with: (self.state, action))}
            self.state = self.reducer(self.state, action)
            self.stateObservers.forEach { $0.execute(with: self.state) }
        }
    }
    
    /// Subscribe a component to observe the state **after** each change
    ///
    /// - Parameter observer: this closure will be called **when subscribe** and every time **after** state has changed.
    ///
    /// - Returns: A `Disposable`, to stop observation call .dispose() on it, or add it to a `Disposer`
    public func observe(on queue:DispatchQueue? = nil, with observer: @escaping (State) -> Void ) -> Disposable {
        
        var observeCommand: CommandOf<State>
        if let queue = queue {
            observeCommand = CommandOf(action: observer).async(on: queue)
        } else {
            observeCommand = CommandOf(action: observer)
        }
        
        coreDispatchQueue.async {
            self.stateObservers.insert(observeCommand)
            observeCommand.execute(with: self.state)
        }
        
        let stopObservation = Disposable(
            id: "remove the observer \(String(describing: observer)) from observers list",
            action: { [weak observeCommand] in
                guard let observeCommand = observeCommand else { return }
                self.stateObservers.remove(observeCommand)
        })
        
        return stopObservation.async(on: coreDispatchQueue)
    }
    
    /// Subscribes to observe Actions and the old State **before** the change when action has happened.
    /// Recommended using only for debugging purposes.
    /// ```
    /// core.onAction{ action, state in
    ///     print(action)
    /// }
    /// ```
    /// - Parameter observe: this closure will be executed whenever the action happened **before** the state change
    ///
    /// - Returns: A `Disposable`, to stop observation call .dispose() on it, or add it to a `Disposer`
    public func onAction(execute observe: @escaping (State, Action) -> Void) -> Disposable {
        let observeCommand = CommandOf(action: observe)
        
        coreDispatchQueue.async {
            self.actionsObservers.insert(observeCommand)
        }
        
        let stopObservation = Disposable(
            id: "remove the Actions observe: \(String(describing: observe)) from observers list",
            action:{ [weak observeCommand] in
                guard let command = observeCommand else { return }
                self.actionsObservers.remove(command)
        })
        
        return stopObservation.async(on: coreDispatchQueue)
    }
}

