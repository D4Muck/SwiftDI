//
// Created by Christoph Muck on 17.02.18.
// Copyright (c) 2018 Christoph Muck. All rights reserved.
//

import Foundation

func calculateComponents() -> [Component] {
    let allModules = getAllModules()
    let subcomponentGraph = calculateSubcomponentParents(from: allModules)
    var components = getComponentAndSubcomponentTypes().map { type -> Component in
        let methods = type.methods.map { ComponentMethod(name: $0.shortName, typeName: $0.returnTypeName.name) }
        let requiredTypeNames = methods.map { $0.typeName }
        let includedModuleNames = (type.annotations["Modules"] as? String)?.split(separator: ",").map(String.init) ?? []
        let includedModules = includedModuleNames.map { includedModuleName in
            return allModules.first { $0.name == includedModuleName } ?? moduleNotFondError(name: includedModuleName)
        }
        let order = calculateDependencyOrder(forTypeNames: requiredTypeNames, andIncludedModules: includedModules)
        return Component(name: type.name, module: type.module ?? "", order: order, methods: methods, modules: includedModules)
    }

    let subcomponents = subcomponentGraph.map { entry -> Subcomponent in
        let subcomponentName = entry.key
        let parentName = entry.value

        let index = components.index { $0.name == subcomponentName } ?? error(msg: "Somethings wrong with component parent resolving!")
        let subcomponent = components.remove(at: index)
        let parentcomponent = components.first { $0.name == parentName } ?? error(msg: "Somethings wrong with component parent resolving!")
        return subcomponent.toSubcomponent(withParent: parentcomponent)
    }

    return components + subcomponents
}

func error<R>(msg: String) -> R {
    fatalError(msg)
}

func moduleNotFondError<T>(name: String) -> T {
    fatalError("Module with name \"\(name)\" not found!")
}

func calculateSubcomponentParents(from modules: [Module]) -> [String: String] {
    return modules.filter { $0.declaredSubcomponents.count > 0 }
        .reduce(into: [String: String]()) { map, module in
            let components = findComponentTypesThat(haveInstalled: module)
            if (components.count > 1) {
                fatalError("\(module.name) is installed multiple times: \(components.map { $0.name }.joined(separator: ", "))!")
            }
            if let component = components.first {
                module.declaredSubcomponents.forEach {
                    map[$0] = component.name
                }
            }
        }
}

func findComponentTypesThat(haveInstalled module: Module) -> [Type] {
    return getComponentAndSubcomponentTypes().filter { type in
        let includedModuleNames = (type.annotations["Modules"] as? String)?.split(separator: ",").map(String.init) ?? []
        return includedModuleNames.contains(module.name)
    }
}

func getComponentAndSubcomponentTypes() -> [Type] {
    return types.protocols.filter { $0.annotations.keys.contains { ["Component", "Subcomponent"].contains($0) } }
}

func getAllComponentsSeparatedByModule() -> [String: [Component]] {
    return calculateComponents().reduce(into: [String: [Component]]()) { dict, element in
        var factories: [Component]
        if let arr = dict[element.module] {
            factories = arr
        } else {
            factories = [Component]()
        }
        factories.append(element)
        dict[element.module] = factories
    }
}
