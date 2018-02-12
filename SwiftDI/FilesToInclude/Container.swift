//
// Created by Christoph Muck on 11.02.18.
// Copyright (c) 2018 AppFactory GmbH. All rights reserved.
// Container.swift
//

class DependencyType: CustomStringConvertible {
    let identifier: String
    let typeName: String
    var dependencies = [DependencyType]()
    var dependant = [DependencyType]()
    var done = false

    init(identifier: String,
         typeName: String) {
        self.identifier = identifier
        self.typeName = typeName
    }

    var description: String {
        return identifier + "," + dependant.description + ": " + dependencies.description
    }
}

var dependencyTypes = [String: DependencyType]()

func createOrGetDepTypeS(of name: String) -> DependencyType {
    let id = name
    let dependencyType: DependencyType
    if (!dependencyTypes.keys.contains(id)) {
        dependencyType = DependencyType(
                identifier: id,
                typeName: id
        )
        dependencyTypes[id] = dependencyType
    } else {
        dependencyType = dependencyTypes[id]!
    }
    return dependencyType
}

func createOrGetDepTypeF(of f: Factory) -> DependencyType {
    return createOrGetDepTypeS(of: f.typeName)
}

func createOrGetDepTypeD(of d: Dependency) -> DependencyType {
    return createOrGetDepTypeS(of: d.dependencyTypeName)
}

func calculateOrder() -> [DependencyType] {
    let factories = getAllFactories()

    factories.forEach { factory in
        factory.dependencies.forEach { dependency in
            let ownType = createOrGetDepTypeF(of: factory)
            let dependencyType = createOrGetDepTypeD(of: dependency)
            if !ownType.dependencies.map({ $0.identifier }).contains(dependencyType.identifier) {
                ownType.dependencies.append(dependencyType)
                dependencyType.dependant.append(ownType)
            }
        }
    }

    var order = [DependencyType]()
    var unvisited = [DependencyType]()
    var lastCount = -1

    repeat {
        unvisited.append(contentsOf: dependencyTypes.values.filter { $0.dependencies.filter { !$0.done }.count == 0 })
        while unvisited.count != 0 {
            let currentType = unvisited.removeFirst()
            order.append(currentType)
            currentType.done = true
            dependencyTypes.removeValue(forKey: currentType.identifier)
        }

        let currentCount = dependencyTypes.values.count
        if (lastCount == currentCount) {
            fatalError("Cycle detected!")
        }
        lastCount = currentCount

    } while (dependencyTypes.values.count != 0)

    return order
}

func firstLetterLowercased(_ string: String) -> String {
    return string.prefix(1).lowercased() + string.dropFirst()
}
