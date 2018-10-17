//
//  FunctionalFoundation.h
//  Unicore
//
//  Created by Maxim Bazarov on 4/2/18.
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
class Command<T> {
    
    let action: (T) -> () // underlying closure
    
    // Block of `context` defined variables. Allows Command to be debugged
    private let file: StaticString
    private let function: StaticString
    private let line: Int
    private let id: String
    
    public
    init(id: String = "unnamed",
         file: StaticString = #file,
         function: StaticString = #function,
         line: Int = #line,
         action: @escaping (T) -> ()) {
        self.id = id
        self.action = action
        self.function = function
        self.file = file
        self.line = line
    }
    
    public
    func execute(with value: T) {
        action(value)
    }
    
    /// Placeholder for do nothing PlainCommand
    public
    static var nop: Command { return Command(id: "nop") { _ in } }
    
    /// Support for Xcode quick look feature.
    @objc
    public
    func debugQuickLookObject() -> AnyObject? {
        return """
            type: \(String(describing: type(of: self)))
            id: \(id)
            file: \(file)
            function: \(function)
            line: \(line)
            """ as NSString
    }
}


// MARK: - Plain (void typed) command

public
typealias PlainCommand = Command<Void>

public
extension Command where T == Void {
    func execute() {
        execute(with: ())
    }
}

/// Allows PlainCommands to be compared and stored in sets and dicts.
/// Uses `ObjectIdentifier` to distinguish between PlainCommands
extension Command: Hashable {
    public static
    func ==(left: Command, right: Command) -> Bool {
        return ObjectIdentifier(left) == ObjectIdentifier(right)
    }
    
    public
    var hashValue: Int { return ObjectIdentifier(self).hashValue }
}

// MARK: - Value binding
public
extension Command {
    /// Creates new plain command with value inside
    ///
    /// - Parameter value: Value to be bound
    /// - Returns: PlainCommand with having `value` when executed
    public
    func bound(to value: T) -> PlainCommand {
        return PlainCommand { self.execute(with: value) }
    }
}

// MARK: Map
extension Command {
    
    func map<U>(transform: @escaping (U) -> T) -> Command<U> {
        return Command<U> { value in self.execute(with: transform(value)) }
    }
}

// MARK: Queueing
public
extension Command {
    
    public
    func async(on queue: DispatchQueue) -> Command {
        return Command { value in
            queue.async {
                self.execute(with: value)
            }
        }
    }
}

