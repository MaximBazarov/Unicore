//
//  Command.swift
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
class CommandOf<T> {
    
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
    static var nop: CommandOf { return CommandOf(id: "nop") { _ in } }
    
    /// Support for Xcode quick look feature.
    @objc
    public
    func debugQuickLookObject() -> AnyObject? {
       return debugDescription as NSString
    }
}

extension CommandOf: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        return """
            \(String(describing: type(of: self))) id: \(id)
            \tfile: \(file)
            \tfunction: \(function)
            \tline: \(line)
            """
    }

}


// MARK: - Plain (void typed) command

public
typealias Command = CommandOf<Void>

public
extension CommandOf where T == Void {
    func execute() {
        execute(with: ())
    }
}

/// Allows Command to be compared and stored in sets and dicts.
/// Uses `ObjectIdentifier` to distinguish between Commands
extension CommandOf: Hashable, Equatable {
    public static 
    func ==(left: CommandOf, right: CommandOf) -> Bool {
        return ObjectIdentifier(left) == ObjectIdentifier(right)
    }

    public 
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self).hashValue)
    }

    #if !swift(>=5)
    public 
    var hashValue: Int { return ObjectIdentifier(self).hashValue }
    #endif
}


// MARK: - Value binding
public
extension CommandOf {
    /// Creates new plain command with value inside
    ///
    /// - Parameter value: Value to be bound
    /// - Returns: Command with having `value` when executed
    func bound(to value: T) -> Command {
        return Command { self.execute(with: value) }
    }
}

// MARK: Map
extension CommandOf {
    
    func map<U>(transform: @escaping (U) -> T) -> CommandOf<U> {
        return CommandOf<U> { value in self.execute(with: transform(value)) }
    }
}

// MARK: - Queueing
public
extension CommandOf {
    
    func async(on queue: DispatchQueue) -> CommandOf {
        return CommandOf { value in
            queue.async {
                self.execute(with: value)
            }
        }
    }
}

