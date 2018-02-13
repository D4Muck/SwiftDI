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
    var inititializationType: InitializationType = .body

    init(identifier: String,
         typeName: String) {
        self.identifier = identifier
        self.typeName = typeName
    }

    var description: String {
        return identifier + "," + dependant.description + ": " + dependencies.description
    }
}

enum InitializationType {
    case module, body
}

struct Component {
    let name: String
    let order: [DependencyType]
    let methods: [ComponentMethod]
}

struct ComponentMethod {
    let name: String
    let typeName: String
}

class ComponentCalculator {

    var dependencyTypes: [String: DependencyType] = [:]
    let allFactories: [Factory]
    let types: Types

    init(types: Types, factories: [Factory]) {
        self.types = types
        self.allFactories = factories
    }

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

    func calculateOrder(forFactories factories: [Factory]) -> [DependencyType] {
        dependencyTypes = [:]

        factories.forEach { factory in
            let ownType = createOrGetDepTypeF(of: factory)
            factory.dependencies.forEach { dependency in
                let dependencyType = createOrGetDepTypeD(of: dependency)

                if dependency.isModule {
                    dependencyType.inititializationType = .module
                }

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

    func getAllComponents() -> [Component] {
        return types.protocols.filter { $0.annotations.keys.contains("Component") }.map { type -> Component in
            let methods = type.methods.map { ComponentMethod(name: $0.shortName, typeName: $0.returnTypeName.name) }

            let neededFactories = methods.map { $0.typeName }

            let initialFactories = allFactories.filter { neededFactories.contains($0.typeName) }
            var factories = initialFactories
            initialFactories.forEach {
                addDependencyFactories(factory: $0, factories: &factories)
            }

            return Component(name: type.name, order: calculateOrder(forFactories: factories), methods: methods)
        }
    }

    func addDependencyFactories(factory: Factory, factories: inout [Factory]) {
        factory.dependencies.forEach { d in
            if let f = allFactories.first(where: { $0.typeName == d.dependencyTypeName }) {
                if (!factories.contains(where: { $0.typeName == f.typeName })) {
                    factories.append(f)
                    addDependencyFactories(factory: f, factories: &factories)
                }
            }
        }
    }
}

func firstLetterLowercased(_ string: String) -> String {
    return string.prefix(1).lowercased() + string.dropFirst()
}

let componentCalculator = ComponentCalculator(types: types, factories: getAllFactories())
