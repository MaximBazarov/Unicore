/// Function to proceed from current state to a new one
public typealias Mutator<State> = (State, Action) -> State

