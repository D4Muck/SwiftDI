//
//  Provider.swift
//  SwiftDIRuntime
//
//  Created by Christoph Muck on 12.02.18.
//  Copyright © 2018 Christoph Muck. All rights reserved.
//

open class Provider<T> {

    public init() {
    }

    open func get() -> T {
        fatalError("Please override me!")
    }
}
