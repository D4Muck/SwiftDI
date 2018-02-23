//
// Created by Christoph Muck on 23.02.18.
// Copyright (c) 2018 Christoph Muck. All rights reserved.
//

func calculateComponentBuilders() -> [ComponentBuilder] {
    let allComponents = calculateComponents()
    return  types.protocols.filter { $0.annotations.keys.contains("Builder") }
        .map { (type: Type) -> ComponentBuilder in
            guard let buildMethod = type.methods.first(where: { $0.shortName == "build" }) else {
                fatalError("\(type.name) has no build() method")
            }
            guard let componentType = buildMethod.returnType else {
                fatalError("No accessible component type in \(type.name) build() method")
            }
            guard let component = allComponents.first(where: { $0.name == componentType.name }) else {
                fatalError("No component with type \(componentType.name) found!")
            }
            return ComponentBuilder(component: component, name: type.name)
        }
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
