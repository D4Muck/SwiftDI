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
    let scope: String?

    init(
        name: String,
        module: String,
        order: [Dependency],
        methods: [ComponentMethod],
        modules: [Module],
        scope: String?
    ) {
        self.name = name
        self.module = module
        self.order = order
        self.methods = methods
        self.modules = modules
        self.scope = scope
    }

    var lowercasedName: String {
        return name.prefix(1).lowercased() + name.dropFirst()
    }

    var initializerParametersContent: String {
        return getInitializerParameters().joined(separator: ",\n        ")
    }

    func getInitializerParameters() -> [String] {
        return modules.map { $0.lowercasedName + ": " + $0.name }
    }

    func declaresDependencyAtLevel(dependency: Dependency, currentLevel: Int) -> Int {
        if case .scoped(let dependencyScopeName) = dependency.trait {
            if (self.scope == dependencyScopeName) {
                return currentLevel
            } else {
                if (!hasScopeInHierachy(scopeName: dependencyScopeName)) {
                    fatalError("\(dependency.typeName) has scope \(dependencyScopeName) which is not in component hierachy!")
                }
            }
        }

        let isIncludedInOrder = order.contains(where: { $0.typeName == dependency.typeName })

        if let subcomponent = self as? Subcomponent {
            let level = subcomponent.parent.declaresDependencyAtLevel(dependency: dependency, currentLevel: currentLevel + 1)
            if (isIncludedInOrder && level == 0) {
                return currentLevel
            } else {
                return level
            }
        }

        if isIncludedInOrder {
            return currentLevel
        } else {
            return 0
        }
    }

    func hasScopeInHierachy(scopeName: String) -> Bool {
        if (scopeName == scope) {
            return true
        }

        if let subcomponent = self as? Subcomponent {
            return subcomponent.parent.hasScopeInHierachy(scopeName: scopeName)
        }

        return false
    }

    func hasToDeclareDependecyItsself(dependency: Dependency) -> Bool {
        return declaresDependencyAtLevel(dependency: dependency, currentLevel: 0) == 0
    }

    var dependenciesToDeclare: [Dependency] {
        return order.filter { hasToDeclareDependecyItsself(dependency: $0) }
    }

    var properties: String {
        let componentFactory = ["private var \(lowercasedName)ImplFactory: InstanceFactory<\(name)Impl>!"]
        return (componentFactory
            + modules.map { "private var " + $0.lowercasedName + "Factory" + ": InstanceFactory<" + $0.name + ">!" }
            + dependenciesToDeclare.map { "fileprivate var " + $0.lowercasedTypeName + "Factory" + ": " + $0.typeName + "Factory!" })
            .joined(separator: "\n    ")
    }

    var initializerContent: String {
        // @formatter:off
        let componentFactory = ["""
                \(lowercasedName)ImplFactory = InstanceFactory<\(name)Impl>(
                        instance: self
                    )
        """]
        // @formatter:on
        return (componentFactory + modules.map {
            // @formatter:off
            """
                    \($0.lowercasedName)Factory = InstanceFactory<\($0.name)>(
                        instance: \($0.lowercasedName)
                    )
            """
            // @formatter:on
        } + dependenciesToDeclare.map {
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
            let declaredAtLevel = declaresDependencyAtLevel(dependency: $0.dependency, currentLevel: 0)
            let parentAccesser = String(repeating: "parentComponent.", count: declaredAtLevel)
            return $0.dependency.lowercasedTypeName + "Factory" + ": " + parentAccesser + $0.dependency.lowercasedTypeName + "Factory"
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
            scope: scope,
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
        scope: String?,
        parent: Component
    ) {
        self.parent = parent
        super.init(name: name, module: module, order: order, methods: methods, modules: modules, scope: scope)
    }

    override func getInitializerParameters() -> [String] {
        return ["parentComponent: " + parent.name + "Impl"] + super.getInitializerParameters()
    }
}
