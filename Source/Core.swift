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

protocol Dispatcher {
    func dispatch(_ action: Action)
}

public protocol Action {}

public typealias Reducer<State> = (State, Action) -> State

/// The Core, is a dispatcher and a state keeper
///
/// Main part of the unicore
public final class Core<State> {
    
    private let coreDispatchQueue = DispatchQueue(label: "com.unicore.core-lock-queue")
    
    private var state: State
    private let reducer: Reducer<State>
    private var actionsObservers: Set<CommandOf<(State, Action)>> = []
    private var stateObservers:  Set<CommandOf<State>> = []
    
    
    /// Core initialization
    ///
    /// - Parameters:
    ///   - state: initial state
    ///   - reducer: function to obtain a new state regarding action
    public init(state: State, reducer: @escaping Reducer<State>) {
        self.state = state
        self.reducer = reducer
    }
    
}

extension Core: Dispatcher {
    
    /// This method is the only way mutate the state.
    /// But instead of mutating directly, the action must be dispatched.
    /// After that mutator will be applied to the current state producing its new version applying the action.
    /// And then every subscriber will be notified with the new version of the state.
    ///
    /// - Parameter action: Action regarding which state must be mutated.
    public func dispatch(_ action: Action) {
        coreDispatchQueue.async {
            self.actionsObservers.forEach {$0.execute(with: (self.state, action))}
            self.state = self.reducer(self.state, action)
            self.stateObservers.forEach { $0.execute(with: self.state) }
        }
    }
    
}

// MARK: - Observable -
extension Core {
    
    
    /// Subscribe component to observe the state **after** each change
    ///
    /// - Parameter command: this command will be called every time **after** state has changed
    /// **and when subscribe**
    ///
    /// - Returns: `PlainCommand` to stop observation
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
            id: "remove the observer \(observer) from observers list",
            action: { [weak observeCommand] in
                guard let observeCommand = observeCommand else { return }
                self.stateObservers.remove(observeCommand)
        })
        
        return stopObservation.async(on: coreDispatchQueue)
    }
}

// MARK: - Middleware -
extension Core {
    
    /// Subscribes to observe Actions and the state **before** the change
    ///
    /// ```
    /// core.onAction{ action, state in
    ///     print(action)
    /// }
    /// ```
    /// - Parameter observe: this closure will be executed whenever the action happened **before** the state change
    ///
    /// - Returns: `PlainCommand` to stop observation
    public func onAction(execute observe: @escaping (State, Action) -> Void) -> Disposable {
        let observeCommand = CommandOf(action: observe)
        
        coreDispatchQueue.async {
            self.actionsObservers.insert(observeCommand)
        }
        
        let stopObservation = Disposable(
            id: "remove the Actions observe: \(observe) from observers list",
            action:{ [weak observeCommand] in
                guard let command = observeCommand else { return }
                self.actionsObservers.remove(command)
        })
        
        return stopObservation.async(on: coreDispatchQueue)
    }
}

