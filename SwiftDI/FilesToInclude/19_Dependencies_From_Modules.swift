//
// Created by Christoph Muck on 17.02.18.
// Copyright (c) 2018 Christoph Muck. All rights reserved.
//

func getAllModules() -> [Module] {
    return types.classes.filter { $0.annotations.keys.contains("Module") }
        .map { type -> Module in
            let subcomponentNames = getDeclaredSubcomponents(of: type)
            var builderDependencies = [Dependency]()
            if let parentComponentType = findComponentTypesThat(haveInstalledModuleWithName: type.name).first {
                builderDependencies = subcomponentNames.map { builderName(forComponent: $0) }.flatMap { $0 }
                    .map { builderName in
                        return Dependency(
                            typeName: builderName + "Impl",
                            type: nil,
                            module: parentComponentType.module ?? "",
                            dependencies: [DependencyDeclaration(
                                name: "parentComponent",
                                dependency: Dependency(
                                    typeName: parentComponentType.name + "Impl",
                                    type: nil,
                                    module: "",
                                    dependencies: [],
                                    createdBy: .initializer,
                                    trait: .unscoped
                                ),
                                injectMethod: .initializer,
                                isProvider: false,
                                declaredTypeName: parentComponentType.name + "Impl",
                                declaredType: nil
                            )],
                            createdBy: .initializer,
                            trait: .unscoped,
                            accessLevel: ""
                        )
                    }
            }

            let providedDependencies = type.methods.filter { $0.annotations.keys.contains("Provides") }.map {
                return Dependency(
                    typeName: $0.returnTypeName.name,
                    type: $0.returnType,
                    module: type.module ?? "",
                    dependencies: [getDependency(forType: type)],
                    createdBy: .module(moduleName: type.name, methodName: $0.shortName),
                    trait: trait(fromAnnotations: $0.annotations),
                    accessLevel: $0.accessLevel
                )
            }
            return Module(
                name: type.name,
                module: type.module ?? "",
                dependencies: (providedDependencies + builderDependencies),
                type: type,
                declaredSubcomponents: getDeclaredSubcomponents(of: type)
            )
        }
}

func getDeclaredSubcomponents(of type: Type) -> [String] {
    return (type.annotations["Subcomponents"] as? String)?.split(separator: ",").map(String.init) ?? []
}

func getDependency(forType type: Type) -> DependencyDeclaration {
    return DependencyDeclaration(
        name: type.name,
        dependency: Dependency(
            typeName: type.name,
            type: type,
            module: type.module ?? "",
            dependencies: [],
            createdBy: .initializer,
            trait: .unscoped),
        injectMethod: .initializer,
        isProvider: false,
        declaredTypeName: type.name,
        declaredType: type
    )
}

func getAllModulesSeparatedByModule() -> [String: [Module]] {
    return getAllModules().reduce(into: [String: [Module]]()) { dict, element in
        var factories: [Module]
        if let arr = dict[element.module] {
            factories = arr
        } else {
            factories = [Module]()
        }
        factories.append(element)
        dict[element.module] = factories
    }
}
