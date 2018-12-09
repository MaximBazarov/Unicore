//
//  AtomicValue.swift
//  Unicore
//
//  Created by Maxim Bazarov on 09.12.18.
//  Copyright © 2018 Maksim Bazarov. All rights reserved.
//

import Foundation

/// Gives your value thread protection
public final class AtomicValue<T> {
    
    public var value: T {
        get {
            return lock.sync {
                return self._value
            }
        }
        
        set {
            lock.async {
                self._value = newValue
            }
        }
    }
    
    private let lock = DispatchQueue(label: "code.unicore.atomic-value-lock")
    private var _value: T

    public init(_ value: T) {
        self._value = value
    }
    
}
