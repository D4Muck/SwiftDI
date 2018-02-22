//
// Created by Christoph Muck on 17.02.18.
// Copyright (c) 2018 Christoph Muck. All rights reserved.
//

import Foundation

class Component {
    let name: String
    let module: String
    let order: [Dependency]
    let methods: [ComponentMethod]
    let modules: [Module]

    init(
        name: String,
        module: String,
        order: [Dependency],
        methods: [ComponentMethod],
        modules: [Module]
    ) {
        self.name = name
        self.module = module
        self.order = order
        self.methods = methods
        self.modules = modules
    }

    var modulesToImport: String {
        let allModules: [String] = getAllModules()
        return allModules.filter { s in s.count != 0 && s != module }
            .map { "i" + "mport " + $0 }
            .joined(separator: "\n")
    }

    func getAllModules() -> Array<String> {
        let allModules = Set(modules.map { $0.module } + order.map { $0.module })
        return Array(allModules)
    }

    var initializerParametersContent: String {
        return getInitializerParameters().joined(separator: ",\n        ")
    }

    func getInitializerParameters() -> [String] {
        return modules.map { $0.lowercasedName + ": " + $0.name }
    }

    var properties: String {
        return (modules.map { "private let " + $0.lowercasedName + "Factory" + ": InstanceFactory<" + $0.name + ">" }
            + order.map { "private let " + $0.lowercasedTypeName + "Factory" + ": " + $0.typeName + "Factory" })
            .joined(separator: "\n    ")
    }

    var initializerContent: String {
        return (modules.map {
            // @formatter:off
            """
                    \($0.lowercasedName)Factory = InstanceFactory<\($0.name)>(
                        instance: \($0.lowercasedName)
                    )
            """
            // @formatter:on
        } + order.map {
            // @formatter:off
            """
                    \($0.lowercasedTypeName)Factory = \($0.typeName)Factory(
                        \(parametersForType($0))
                    )
            """
            // @formatter:on
        }).joined(separator: "\n")
    }

    var renderedMethods: String {
        return methods.map { method in
            return """
                func \(method.name)() -> \(method.typeName) {
                    return self.\(method.lowercasedTypeName)Factory.get()
                }
            """
        }.joined(separator: "\n")
    }

    func parametersForType(_ type: Dependency) -> String {
        return type.dependencies.map {
            $0.dependency.lowercasedTypeName + "Factory" + ": " + $0.dependency.lowercasedTypeName + "Factory"
        }.joined(separator: ",\n            ")
    }

    var rendered: String {
        // @formatter:off
        return """
        class \(name)Impl: \(name) {

            \(properties)

            init(
                \(initializerParametersContent)
            ) {
        \(initializerContent)
            }

        \(renderedMethods)
        }
        """
        // @formatter:on
    }

    func toSubcomponent(withParent parent: Component) -> Subcomponent {
        return Subcomponent(
            name: name,
            module: module,
            order: order,
            methods: methods,
            modules: modules,
            parent: parent
        )
    }

}

struct ComponentMethod {
    let name: String
    let typeName: String
    var lowercasedTypeName: String {
        return typeName.prefix(1).lowercased() + typeName.dropFirst()
    }
}

class Subcomponent: Component {

    let parent: Component

    init(
        name: String,
        module: String,
        order: [Dependency],
        methods: [ComponentMethod],
        modules: [Module],
        parent: Component
    ) {
        self.parent = parent
        super.init(name: name, module: module, order: order, methods: methods, modules: modules)
    }

    override func getInitializerParameters() -> [String] {
        return ["parentComponent: " + parent.name + "Impl"] + super.getInitializerParameters()
    }

    override func getAllModules() -> Array<String> {
        return super.getAllModules() + [parent.module]
    }
}
