//
// Created by Christoph Muck on 17.02.18.
// Copyright (c) 2018 Christoph Muck. All rights reserved.
//

class Factory {

    init(dependency: Dependency) {
        self.dependency = dependency
    }

    let dependency: Dependency

    var module: String {
        return dependency.module
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
            return "        instance = \(moduleName)Factory.get().\(methodName)()"
        }
        return concatPropertyInjectionTo(toString: result)
    }

    func concatPropertyInjectionTo(toString: String) -> String {
        let propertyInjectedDeps = properties.filter { $0.dependency.injectMethod == .property }
                .map {
                    "instance." + $0.dependency.name + " = " + $0.instanceCreator
                }.joined(separator: "\n        ")
        return toString + "\n        " + propertyInjectedDeps
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
        return typeName.prefix(1).lowercased() + typeName.dropFirst()
    }

    var typeName: String {
        return dependency.dependency.typeName + "Factory"
    }

    var instanceCreator: String {
        let suffix = (dependency.isProvider) ? "" : ".get()"
        return name + suffix
    }
}
