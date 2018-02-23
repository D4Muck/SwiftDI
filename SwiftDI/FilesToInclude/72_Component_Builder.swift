//
// Created by Christoph Muck on 23.02.18.
// Copyright (c) 2018 Christoph Muck. All rights reserved.
//

struct ComponentBuilder {

    let component: Component

    var module: String {
        return component.module
    }

    var modules: [Module] {
        return component.modules
    }

    var properties: String {
        let parent = getParentNameOrEmpty().map { "private let parentComponent: " + $0 + "Impl" }
        return (parent + modules.map { "private var " + $0.lowercasedName + ": " + $0.name + "?" })
            .joined(separator: "\n    ")
    }

    var initParameters: String {
        return getParentNameOrEmpty().map { "parentComponent: " + $0 + "Impl" }.joined(separator: "\n        ")
    }

    var initContent: String {
        return "self.parentComponent = parentComponent"
    }

    func getParentNameOrEmpty() -> [String] {
        return [getSubcomponent()?.parent.name].flatMap { $0 }
    }

    func getSubcomponent() -> Subcomponent? {
        return self.component as? Subcomponent
    }

    var moduleMethods: String {
        return modules.map {
            """
                func with(\($0.lowercasedName): \($0.name)) -> \(name) {
                    self.\($0.lowercasedName) = \($0.lowercasedName)
                    return self
                }
            """
        }.joined(separator: "\n\n")
    }

    var buildMethodGuards: String {
        return modules.map {
            """
                    guard let \($0.lowercasedName) = \($0.lowercasedName) else {
                        fatal_error(\"\($0.name) not set!\" )
                    }
            """
        }.joined(separator: "\n")
    }

    var componentInitializerParameters: String {
        let parent = getParentNameOrEmpty().map { _ in "parentComponent: parentComponent" }
        return (parent + modules.map { "\($0.lowercasedName): \($0.lowercasedName)" })
            .joined(separator: ",\n            ")
    }

    var name: String {
        return component.name + "BuilderImpl"
    }

}
