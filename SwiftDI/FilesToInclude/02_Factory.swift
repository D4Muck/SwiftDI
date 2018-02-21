//
// Created by Christoph Muck on 17.02.18.
// Copyright (c) 2018 Christoph Muck. All rights reserved.
//

import Foundation

class Factory {

    init(dependency: Dependency) {
        self.dependency = dependency
    }

    let dependency: Dependency

    var module: String {
        return dependency.module
    }

    var dependencyCount: Int {
        return dependency.dependencies.count
    }

    var visibility: String {
        return dependency.accessLevel
    }

    var name: String {
        return dependency.typeName + "Factory"
    }

    var providedTypeName: String {
        return dependency.typeName
    }

    lazy var properties: [DependencyProperty] = { [unowned self] in
        return dependency.dependencies.map { DependencyProperty(dependency: $0) }
    }()

    var instantiation: String {
        let result: String
        switch dependency.createdBy {
        case .initializer:
            result = """
                    instance = \(dependency.typeName) (
                        \(inititializerCreationContent)
                    )
            """
        case .storyboard(let name, let id):
            result = """
                    instance = UIStoryboard(name: \"\(name)\", bundle: nil)
                    .instantiateViewController(withIdentifier: \"\(id)\")
                    as! \(providedTypeName)//
            """
        case .module(let moduleName, let methodName):
            return "        instance = \(lowercasedString(moduleName))Factory.get().\(methodName)()"
        }
        return concatPropertyInjectionTo(toString: result)
    }

    var getMethodContent: String {
        switch dependency.trait {
        case .normal:
            return instantiation
        case .singleton:
            return "        instance = singletonInstance"
        }
    }

    var additionalContentInClass: String {
        switch dependency.trait {
        case .singleton:
            return """
                private lazy var singletonInstance: \(providedTypeName) = {
                    let \(instantiation.trimmingCharacters(in: .whitespaces))
                    return instance
                }()
            """
        default:
            return ""
        }
    }

    func lowercasedString(_ string: String) -> String {
        return string.prefix(1).lowercased() + string.dropFirst()
    }

    func concatPropertyInjectionTo(toString: String) -> String {
        let propertyInjectedDeps = properties.filter { $0.dependency.injectMethod == .property }

        if (propertyInjectedDeps.count == 0) {
            return toString
        }

        let propertyInjectors = propertyInjectedDeps.map {
            "instance." + $0.dependency.name + " = " + $0.instanceCreator
        }.joined(separator: "\n        ")

        return toString + "\n        " + propertyInjectors
    }

    var inititializerCreationContent: String {
        return properties.filter { $0.dependency.injectMethod == .initializer }
            .map {
                $0.dependency.name + ": " + $0.instanceCreator
            }
            .joined(separator: ",\n            ")
    }

    var initializerParams: String {
        return properties.map { $0.name + ": " + $0.typeName }.joined(separator: ",\n        ")
    }
}

class DependencyProperty {

    init(dependency: DependencyDeclaration) {
        self.dependency = dependency
    }

    let dependency: DependencyDeclaration

    var name: String {
        return dependency.dependency.typeName.prefix(1).lowercased() + dependency.dependency.typeName.dropFirst() + "Factory"
    }

    var typeName: String {
        return "Provider<" + dependency.dependency.typeName + ">"
    }

    var instanceCreator: String {
        let suffix = (dependency.isProvider) ? "" : ".get()"
        return name + suffix
    }
}
