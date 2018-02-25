//
// Created by Christoph Muck on 17.02.18.
// Copyright (c) 2018 Christoph Muck. All rights reserved.
//

func getAllDependencies() -> [Dependency] {
    let dependencies = getDependenciesFromInjectables() + getAllModules().flatMap { $0.dependencies }
    return dependencies + getAdditionalDependencies(fromDependencies: dependencies)
}

func getAdditionalDependencies(fromDependencies dependencies: [Dependency]) -> [Dependency] {
    return dependencies.flatMap { $0.dependencies }
        .reduce(into: [Dependency]()) { (additionalDependencies, d: DependencyDeclaration) in
            if d.isProvider && d.declaredType?.kind == "protocol" {
                let delegatedTypeName = d.dependency.typeName + "Impl"
                let additionalDependency = Dependency(
                    typeName: d.declaredTypeName,
                    type: d.declaredType,
                    module: d.declaredType?.module ?? "",
                    dependencies: [DependencyDeclaration(
                        name: d.dependency.lowercasedTypeName + "ImplFactory",
                        dependency: Dependency(
                            typeName: delegatedTypeName,
                            type: nil,
                            module: d.dependency.module,

                            //egal
                            dependencies: [],
                            createdBy: .initializer,
                            trait: .unscoped,
                            accessLevel: ""
                        ),
                        injectMethod: .initializer,
                        isProvider: false,
                        declaredTypeName: delegatedTypeName,
                        declaredType: nil
                    )],
                    createdBy: .initializer,
                    trait: .delegating(delegatedTypeName: d.dependency.lowercasedTypeName),
                    accessLevel: d.dependency.accessLevel
                )
                additionalDependencies.append(additionalDependency)
            }
        }
}
