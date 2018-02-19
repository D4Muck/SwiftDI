//
// Created by Christoph Muck on 17.02.18.
// Copyright (c) 2018 Christoph Muck. All rights reserved.
//

struct Dependency {
    let typeName: String
    let type: Type?
    let module: String
    let dependencies: [DependencyDeclaration]
    let createdBy: CreationType
    let trait: Trait
    let accessLevel: String

    init(typeName: String, type: Type?, module: String, dependencies: [DependencyDeclaration], createdBy: CreationType, trait: Trait, accessLevel: String) {
        self.typeName = typeName
        self.type = type
        self.module = module
        self.dependencies = dependencies
        self.createdBy = createdBy
        self.trait = trait
        self.accessLevel = accessLevel
    }

    init(typeName: String, type: Type?, module: String, dependencies: [DependencyDeclaration], createdBy: CreationType, trait: Trait) {
        self.init(typeName: typeName, type: type, module: module, dependencies: dependencies, createdBy: createdBy, trait: trait, accessLevel: type?.accessLevel ?? "")
    }

    var lowercasedTypeName: String {
        return typeName.prefix(1).lowercased() + typeName.dropFirst()
    }
}

struct DependencyDeclaration {
    let name: String
    let dependency: Dependency
    let injectMethod: InjectMethod
    let isProvider: Bool

    //Possible that this is a protocol
    let declaredTypeName: String
    let declaredType: Type?
}

enum InjectMethod {
    case initializer, property
}

enum CreationType {
    case initializer, storyboard(name: String, id: String), module(moduleName: String, methodName: String)
}

enum Trait {
    case normal, singleton
}
