//
// Created by Christoph Muck on 17.02.18.
// Copyright (c) 2018 Christoph Muck. All rights reserved.
//

import Foundation

struct Component {
    let name: String
    let module: String
    let order: [Dependency]
    let methods: [ComponentMethod]
    let modules: [Module]
    let subcomponents: [Component]

    var modulesToImport: String {
        let allModules: [String] = Array(unionModulesToImport(with: Set()))
        return allModules.filter { s in s.count != 0 && s != module }
            .map { "i" + "mport " + $0 }
            .joined(separator: "\n")
    }

    func unionModulesToImport(with set: Set<String>) -> Set<String> {
        return set.union(Set(modules.map { $0.module } + order.map { $0.module }))
    }

    var initializerParametersContent: String {
        return modules.map { $0.lowercasedName + ": " + $0.name }.joined(separator: ",\n        ")
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


        \(renderedSubcomponents)
        }
        """
        // @formatter:on
    }

    var renderedSubcomponents: String {
        return subcomponents.map {
            "    " + $0.rendered.split(separator: "\n", omittingEmptySubsequences: false)
                .joined(separator: "\n    ")
        }.joined(separator: "\n")
    }
}

struct ComponentMethod {
    let name: String
    let typeName: String
    var lowercasedTypeName: String {
        return typeName.prefix(1).lowercased() + typeName.dropFirst()
    }
}
