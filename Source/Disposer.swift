//
//  Disposer.swift
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



public class Disposable {
    
    private let disposeCommand: () -> () // underlying closure
    
    // Block of `context` defined variables. Allows Command to be debugged
    private let file: StaticString
    private let function: StaticString
    private let line: Int
    private let id: String
    
    init(id: String = "Dispose Command",
         file: StaticString = #file,
         function: StaticString = #function,
         line: Int = #line,
         action: @escaping () -> ()) {
        self.id = id
        self.disposeCommand = action
        self.function = function
        self.file = file
        self.line = line
    }
    
    func dispose() {
        disposeCommand()
    }
    
    /// Adds this command to be disposed on disposer deinit
    ///
    /// - Parameter disposer: disposer
    func dispose(on disposer: Disposer) {
        disposer.add(disposal: self)
    }
    
    /// Support for Xcode quick look feature.
    @objc func debugQuickLookObject() -> AnyObject? {
        return debugDescription as NSString
    }
}

extension Disposable: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        return """
        \(String(describing: type(of: self))) id: \(id)
        \tfile: \(file)
        \tfunction: \(function)
        \tline: \(line)
        """
    }
    
}

extension Disposable {
    
    func async(on queue: DispatchQueue) -> Disposable {
        return Disposable {
            queue.async {
                self.dispose()
            }
        }
    }
}


/// Convenient object to add to your class in case you want to dispose of your subscriptions on deinit.
///
/// **Usage**
/// ```
/// class SomeSubscriber {
///
///     // add the disposer property
///     private let disposer = Disposer()
///
///     // ...
///     func bind() {
///
///         core.observe { state in
///             //...
///         }.dispose(on: disposer)
///         // will be disposed when this object deinits
///     }
/// }
/// ```
public
final class Disposer {
    
    private var disposals: [Disposable] = []
    private let lockQueue = DispatchQueue(label: "com.unicore.disposer-lock-queue")
    
    /// Adds plain command to be executed when this object deinits
    ///
    /// - Parameter disposal: plain command to execute
    public
    func add(disposal: Disposable) {
        lockQueue.async {
            self.disposals.append(disposal)
        }
    }

    public init() {}
    
    deinit {
        disposals.forEach{$0.dispose()}
    }
}
