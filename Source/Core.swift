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

public
final class Core<State> : Dispatcher {
    
    // MARK: - Private -
    private let coreDispatchQueue = DispatchQueue(label: "com.unicore.core-lock-queue")
    private var state: State
    private var mutate: Mutator<State>
    
    private var listeners: Set<Command<(State, Action)>> = []
    private var observers:  Set<Command<State>> = []
    
    public
    typealias DisposeCommand = PlainCommand
    
    public
    init(state: State, mutate: @escaping Mutator<State>) {
        self.state = state
        self.mutate = mutate
    }
    
    
    /// Dispatches an action to the core
    ///
    /// - Parameter action: action to dispatch
    public
    func dispatch(_ action: Action) {
        coreDispatchQueue.async {
            self.listeners.forEach {$0.execute(with: (self.state, action))}
            self.state = self.mutate(self.state, action)
            self.observers.forEach { $0.execute(with: self.state) }
        }
    }

    // MARK: - Observation -
    
    /// Subscribe component to observe the state **after** each change
    ///
    /// - Parameter command: this command will be called every time **after** state has changed
    /// **and when subscribe**
    ///
    /// - Returns: `DisposeCommand` to stop observation
    public
    func observe(on queue:DispatchQueue? = nil, with observer: @escaping (State) -> Void ) -> DisposeCommand {
        var observeCommand: Command<State>
        if let queue = queue {
            observeCommand = Command(action: observer).async(on: queue)
        } else {
            observeCommand = Command(action: observer)
        }

        coreDispatchQueue.async {
            self.observers.insert(observeCommand)
            observeCommand.execute(with: self.state)
        }
        
        let stopObservation = DisposeCommand(id: "Stop observing with  \(observer)") { [weak observeCommand] in
            guard let observeCommand = observeCommand else { return }
            self.observers.remove(observeCommand)
        }.async(on: coreDispatchQueue)
        
        return stopObservation
    }
    
    /// Subscribe listener to listen the state and action **before** the state has changed
    ///
    /// - Parameter command: this command will be called every time **before** state has changed
    ///
    /// - Returns: `DisposeCommand` to stop listening
    public
    func listen(with listener: @escaping (State, Action) -> Void ) -> DisposeCommand {
        let listenerCommand = Command(action: listener)
        
        coreDispatchQueue.async {
            self.listeners.insert(listenerCommand)
        }
        
        let stopObservation = PlainCommand(id: "Stop observing with \(listener)") { [weak listenerCommand] in
            guard let listenerCommand = listenerCommand else { return }
            self.listeners.remove(listenerCommand)
        }.async(on: coreDispatchQueue)
        
        return stopObservation
    }
}

