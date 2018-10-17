//
//  Dispatcher.swift
//  Unicore
//
//  Created by Maksim Bazarov on 17.10.18.
//  Copyright © 2018 Maksim Bazarov. All rights reserved.
//

protocol Dispatcher {
    func dispatch(_ action: Action)
}
