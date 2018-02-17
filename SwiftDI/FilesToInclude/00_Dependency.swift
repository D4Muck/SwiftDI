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
