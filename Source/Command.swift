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

class CommandOf<T> {
    
    let action: (T) -> () // underlying closure
    
    // Block of `context` defined variables. Allows Command to be debugged
    private let file: StaticString
    private let function: StaticString
    private let line: Int
    private let id: String
    
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
    
    func execute(with value: T) {
        action(value)
    }
    
    /// Support for Xcode quick look feature.
    @objc func debugQuickLookObject() -> AnyObject? {
        return debugDescription as NSString
    }
    
}

extension CommandOf: CustomDebugStringConvertible {
    
    var debugDescription: String {
        return """
        \(String(describing: type(of: self))) id: \(id)
        \tfile: \(file)
        \tfunction: \(function)
        \tline: \(line)
        """
    }
    
}

extension CommandOf {
    
    public
    func async(on queue: DispatchQueue) -> CommandOf {
        return CommandOf { value in
            queue.async {
                self.execute(with: value)
            }
        }
    }
}

/// Allows PlainCommands to be compared and stored in sets and dicts.
/// Uses `ObjectIdentifier` to distinguish between PlainCommands
extension CommandOf: Hashable, Equatable {
    public static
        func ==(left: CommandOf, right: CommandOf) -> Bool {
        return ObjectIdentifier(left) == ObjectIdentifier(right)
    }
    
    public
    var hashValue: Int { return ObjectIdentifier(self).hashValue }
}

typealias PlainCommand = CommandOf<Void>
