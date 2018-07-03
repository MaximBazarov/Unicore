import Foundation
import FunctionalFoundation


public
final class Core<State> {
    public
    init(state: State, mutate: @escaping Mutator<State>) {
        self.state = state
        self.mutate = mutate
    }
    
    public
    func dispatch(_ action: Action) {
        coreDispatchQueue.async {
            self.listeners.forEach { $0.execute(with: (self.state, action)) }
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
    /// - Returns: `PlainCommand` to stop observation
    @discardableResult public
    func observe(on queue:DispatchQueue? = nil, with observer: @escaping (State) -> Void ) -> PlainCommand {
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
        
        let stopObservation = PlainCommand(id: "Stop observing with  \(observer)") { [weak observeCommand] in
            guard let observeCommand = observeCommand else { return }
            self.observers.remove(observeCommand)
        }.async(on: coreDispatchQueue)
        
        return stopObservation
    }
    
    /// Subscribe listener to listen the state and action **before** the state has changed
    ///
    /// - Parameter command: this command will be called every time **before** state has changed
    ///
    /// - Returns: `PlainCommand` to stop listening
    @discardableResult public
    func listen(with listener: @escaping (State, Action) -> Void ) -> PlainCommand {
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
    
    // MARK: - Private -
    private let coreDispatchQueue = DispatchQueue(label: "store private queue")
    private var state: State
    private var mutate: Mutator<State>
    
    private var listeners: Set<Command<(State, Action)>> = []
    private var observers:  Set<Command<State>> = []

    
}

