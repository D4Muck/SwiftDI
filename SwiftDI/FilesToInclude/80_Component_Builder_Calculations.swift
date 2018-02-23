//
// Created by Christoph Muck on 23.02.18.
// Copyright (c) 2018 Christoph Muck. All rights reserved.
//

func calculateComponentBuilders() -> [ComponentBuilder] {
    return calculateComponents().map { ComponentBuilder(component: $0) }
}

func getAllComponentBuildersSeparatedByModule() -> [String: [ComponentBuilder]] {
    return calculateComponentBuilders().reduce(into: [String: [ComponentBuilder]]()) { dict, element in
        var factories: [ComponentBuilder]
        if let arr = dict[element.module] {
            factories = arr
        } else {
            factories = [ComponentBuilder]()
        }
        factories.append(element)
        dict[element.module] = factories
    }
}
