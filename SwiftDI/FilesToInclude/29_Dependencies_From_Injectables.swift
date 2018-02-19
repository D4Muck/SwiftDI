//
// Created by Christoph Muck on 17.02.18.
// Copyright (c) 2018 Christoph Muck. All rights reserved.
//

func getDependenciesFromInjectables() -> [Dependency] {
    return types.classes.filter { $0.annotations.keys.contains("Injectable") }.map { type -> Dependency in
        let creationType: CreationType
        let dependencyResolver: DependencyResolver
        if type.annotations.keys.contains("FromStoryboard") {
            creationType = .storyboard(
                name: type.annotations["StoryboardName"] as! String,
                id: type.annotations["StoryboardIdentifier"] as! String
            )
            dependencyResolver = PropertyDependencyResolver(types: types)
        } else {
            creationType = .initializer
            dependencyResolver = CompositeDependencyResolver(
                types: types,
                resolvers: [
                    InitializerDependencyResolver(types: types),
                    PropertyDependencyResolver(types: types)
                ]
            )
        }
        return Dependency(
            typeName: type.name,
            type: type,
            module: type.module!,
            dependencies: dependencyResolver.getDependencies(ofType: type),
            createdBy: creationType,
            trait: trait(fromAnnotations: type.annotations)
        )
    }
}
