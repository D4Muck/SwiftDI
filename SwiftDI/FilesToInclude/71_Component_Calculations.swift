//
// Created by Christoph Muck on 17.02.18.
// Copyright (c) 2018 Christoph Muck. All rights reserved.
//

import Foundation

func calculateComponents() -> [Component] {
    return types.protocols.filter { $0.annotations.keys.contains("Component") }.map { type -> Component in
        let methods = type.methods.map { ComponentMethod(name: $0.shortName, typeName: $0.returnTypeName.name) }
        let requiredTypeNames = methods.map { $0.typeName }
        let (order, modules) = calculateDependencyOrder(forTypeNames: requiredTypeNames)
        return Component(name: type.name, module: type.module!, order: order, methods: methods, modules: modules)
    }
}

func getAllComponentsSeparatedByModule() -> [String: [Component]] {
    return calculateComponents().reduce(into: [String: [Component]]()) { dict, element in
        var factories: [Component]
        if let arr = dict[element.module] {
            factories = arr
        } else {
            factories = [Component]()
        }
        factories.append(element)
        dict[element.module] = factories
    }
}
