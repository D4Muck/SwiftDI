//
// Created by Christoph Muck on 21.02.18.
// Copyright (c) 2018 Christoph Muck. All rights reserved.
//

import Foundation

public class InstanceFactory<T>: Provider<T> {

    let instance: T

    public init(instance: T) {
        self.instance = instance
    }

    override public func get() -> T {
        return instance
    }
}
