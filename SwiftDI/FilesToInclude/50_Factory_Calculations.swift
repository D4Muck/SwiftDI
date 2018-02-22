//
// Created by Christoph Muck on 17.02.18.
// Copyright (c) 2018 Christoph Muck. All rights reserved.
//

func getAllFactories() -> [Factory] {
    return getAllDependencies().map { Factory(dependency: $0) }
}

func getAllFactoriesSeparatedByModule() -> [String: [Factory]] {
    return getAllFactories().reduce(into: [String: [Factory]]()) { dict, element in
        var factories: [Factory]
        if let arr = dict[element.module] {
            factories = arr
        } else {
            factories = [Factory]()
        }
        factories.append(element)
        dict[element.module] = factories
    }
}
