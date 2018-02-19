//
// Created by Christoph Muck on 17.02.18.
// Copyright (c) 2018 Christoph Muck. All rights reserved.
//

func getDependenciesFromModules() -> [Dependency] {
    return types.classes.filter { $0.annotations.keys.contains("Module") }.flatMap { type -> [Dependency] in
        return type.methods.filter { $0.annotations.keys.contains("Provides") }.map {
            return Dependency(
                    typeName: $0.returnTypeName.name,
                    type: $0.returnType,
                    module: type.module!,
                    dependencies: [getDependency(forType: type)],
                    createdBy: .module(moduleName: type.name, methodName: $0.shortName),
                    trait: .normal,
                    accessLevel: $0.accessLevel
            )
        }
    }
}

func getDependency(forType type: Type) -> DependencyDeclaration {
    return DependencyDeclaration(
            name: type.name,
            dependency: Dependency(
                    typeName: type.name,
                    type: type,
                    module: type.module!,
                    dependencies: [],
                    createdBy: .initializer,
                    trait: .normal),
            injectMethod: .initializer,
            isProvider: false,
            declaredTypeName: type.name,
            declaredType: type
    )
}
