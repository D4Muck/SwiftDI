//
// Created by Christoph Muck on 23.02.18.
// Copyright (c) 2018 Christoph Muck. All rights reserved.
//

func calculateComponentBuilders() -> [ComponentBuilder] {
    let allComponents = calculateComponents()
    return getBuilderTypes()
        .map { (type: Type) -> ComponentBuilder in
            let componentType = getComponentType(for: type)
            guard let component = allComponents.first(where: { $0.name == componentType.name }) else {
                fatalError("No component with type \(componentType.name) found!")
            }
            return ComponentBuilder(component: component, name: type.name)
        }
}

func getComponentType(for type: Type) -> Type {
    guard let buildMethod = type.methods.first(where: { $0.shortName == "build" }) else {
        fatalError("\(type.name) has no build() method")
    }
    guard let componentType = buildMethod.returnType else {
        fatalError("No accessible component type in \(type.name) build() method")
    }
    return componentType
}

func getBuilderTypes() -> [Type] {
    return types.protocols.filter { $0.annotations.keys.contains("Builder") }
}

func builderName(forComponent componentName: String) -> String? {
    return getBuilderTypes().filter { type in
        let componentType = getComponentType(for: type)
        return componentType.name == componentName
    }.map { $0.name }.first
}

func getAllComponentBuildersSeparatedByModule() -> [String: [ComponentBuilder]] {
    return calculateComponentBuilders().reduce(into: [String: [ComponentBuilder]]()) { dict, element in
        var factories: [ComponentBuilder]
        if let arr = dict[element.module] {
            factories = arr
        } else {
            factories = [ComponentBuilder]()
        }
        factories.append(element)
        dict[element.module] = factories
    }
}

func dependenciesForComponentBuilders() -> [Dependency] {
    return calculateComponentBuilders().map { builder -> Dependency in
        Dependency(
            typeName: builder.name + "Impl",
            type: nil,
            module: builder.module,
            dependencies: getDependencyDeclarations(from: builder),
            createdBy: .initializer,
            trait: .unscoped,
            accessLevel: "")
    }
}

func getDependencyDeclarations(from builder: ComponentBuilder) -> [DependencyDeclaration] {
    guard let subcomponent = builder.component as? Subcomponent else {
        return []
    }
    return [
        DependencyDeclaration(
            name: "parentComponent",
            dependency: Dependency(
                typeName: subcomponent.parent.name + "Impl",
                type: nil,
                module: subcomponent.parent.module,
                dependencies: [],
                createdBy: .initializer,
                trait: .unscoped,
                accessLevel: ""
            ),
            injectMethod: .initializer,
            isProvider: false,
            declaredTypeName: subcomponent.parent.name + "Impl",
            declaredType: nil
        )
    ]

}
