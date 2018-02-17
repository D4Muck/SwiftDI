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

    var modulesToImport: String {
        let allModules: [String] = Array(Set(modules.map { $0.module } + order.map { $0.module }))
        return allModules.filter { s in s.count != 0 && s != module }
                .map { "i" + "mport " + $0 }
                .joined(separator: "\n")
    }

    var initializerParametersContent: String {
        return modules.map { $0.lowercasedName + ": " + $0.name }.joined(separator: ",\n        ")
    }

    var properties: String {
        return (modules.map { "private let " + $0.lowercasedName + "Factory" + ": " + $0.name + "Factory" }
                + order.map { "private let " + $0.lowercasedTypeName + "Factory" + ": " + $0.typeName + "Factory" })
                .joined(separator: "\n    ")
    }

    var initializerContent: String {
        return (modules.map {
            // @formatter:off
            """
                    \($0.lowercasedName)Factory = \($0.name)Factory(
                        \($0.lowercasedName): \($0.lowercasedName)
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

    func parametersForType(_ type: Dependency) -> String {
        return type.dependencies.map {
            $0.dependency.lowercasedTypeName + "Factory" + ": " + $0.dependency.lowercasedTypeName + "Factory"
        }.joined(separator: ",\n            ")
    }
}

struct ComponentMethod {
    let name: String
    let typeName: String
    var lowercasedTypeName: String {
        return typeName.prefix(1).lowercased() + typeName.dropFirst()
    }
}
