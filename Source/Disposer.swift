//
//  Disposer.swift
//  Unicore
//
//  Created by Maksim Bazarov on 17.10.18.
//  Copyright © 2018 Maksim Bazarov. All rights reserved.
//



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
    
    private var disposals: [PlainCommand] = []
    private let lockQueue = DispatchQueue(label: "com.unicore.disposer-lock-queue")
    
    
    /// Adds plain command to be executed when this object deinits
    ///
    /// - Parameter disposal: plain command to execute
    public
    func add(disposal: PlainCommand) {
        lockQueue.async {
            self.disposals.append(disposal)
        }
    }
    
    deinit {
        disposals.forEach{$0.execute()}
    }
}

// MARK: - PlainCommand syntax sugar
public
extension Command where T == Void {
    
    /// Adds this command to be disposed on disposer deinit
    ///
    /// - Parameter disposer: disposer
    func dispose(on disposer: Disposer) {
        disposer.add(disposal: self)
    }
}

