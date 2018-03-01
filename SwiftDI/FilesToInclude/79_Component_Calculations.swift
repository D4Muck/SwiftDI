//
// Created by Christoph Muck on 17.02.18.
// Copyright (c) 2018 Christoph Muck. All rights reserved.
//

import Foundation

class ComponentToCalculate {
    let name: String
    let module: String
    let methods: [ComponentMethod]
    let includedModules: [Module]
    let scope: String?
    let parent: String?
    var requiredTypeNames: [String]! = [String]()

    init(
        name: String,
        module: String,
        methods: [ComponentMethod],
        includedModules: [Module],
        scope: String?,
        parent: String?
    ) {
        self.name = name
        self.module = module
        self.methods = methods
        self.includedModules = includedModules
        self.scope = scope
        self.parent = parent
    }
}

func calculateComponents() -> [Component] {
    let allModules = getAllModules()
    let subcomponentGraph = calculateSubcomponentParents(from: allModules)
    var componentsToCalculate: [ComponentToCalculate] = getComponentsToCalculate(allModules, subcomponentGraph)

    var components = [Component]()
    repeat {
        let newComponents = getComponentsToCalculateThatHaveNoParents(componentsToCalculate)
            .map { c -> Component in
                let index = componentsToCalculate.index { $0.name == c.name }
                componentsToCalculate.remove(at: index!)

                let order = calculateDependencyOrder(forTypeNames: c.requiredTypeNames, andIncludedModules: c.includedModules)

                order.forEach { dependency in
                    if case .scoped(let scopeName) = dependency.trait,
                       scopeName != c.scope,
                       let component = componentsToCalculate.first(where: { $0.scope == scopeName }) {
                        component.requiredTypeNames.append(dependency.typeName)
                    }
                }


                return Component(name: c.name, module: c.module, order: order, methods: c.methods, modules: c.includedModules, scope: c.scope)
            }
        components.append(contentsOf: newComponents)
    } while componentsToCalculate.count != 0

    return splitIntoComponentsAndSubcomponents(components, subcomponentGraph: subcomponentGraph)
}

func getComponentsToCalculate(_ allModules: [Module], _ subcomponentGraph: [String: String]) -> [ComponentToCalculate] {
    return getComponentAndSubcomponentTypes().map { type -> ComponentToCalculate in
        let methods = type.methods.map { ComponentMethod(name: $0.shortName, typeName: $0.returnTypeName.name) }
        let requiredTypeNames = methods.map { $0.typeName }
        let includedModuleNames = (type.annotations["Modules"] as? String)?.split(separator: ",").map(String.init) ?? []
        let includedModules = includedModuleNames.map { includedModuleName in
            return allModules.first { $0.name == includedModuleName } ?? moduleNotFondError(name: includedModuleName)
        }
        let scope = type.annotations["Scope"] as? String
        let c = ComponentToCalculate(name: type.name, module: type.module ?? "", methods: methods, includedModules: includedModules, scope: scope, parent: subcomponentGraph[type.name])
        c.requiredTypeNames.append(contentsOf: requiredTypeNames)
        return c
    }
}

func getComponentsToCalculateThatHaveNoParents(_ componentsToCalculate: [ComponentToCalculate]) -> [ComponentToCalculate] {
    return componentsToCalculate.reduce(into: [String: Int]()) { map, entry in
            if let _ = map[entry.name] {
            } else {
                map[entry.name] = 0
            }

            if let parent = entry.parent {
                let newCount: Int
                if let count = map[parent] {
                    newCount = count + 1
                } else {
                    newCount = 1
                }
                map[parent] = newCount
            }
        }
        .filter { (e: (key: String, value: Int)) in e.value == 0 }.map { $0.key }
        .map { name in componentsToCalculate.first(where: { (c: ComponentToCalculate) in c.name == name }) }.flatMap { $0 }
}

func splitIntoComponentsAndSubcomponents(_ components: [Component], subcomponentGraph: [String: String]) -> [Component] {
    var components = components
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
    return findComponentTypesThat(haveInstalledModuleWithName: module.name)
}

func findComponentTypesThat(haveInstalledModuleWithName name: String) -> [Type] {
    return getComponentAndSubcomponentTypes().filter { type in
        let includedModuleNames = (type.annotations["Modules"] as? String)?.split(separator: ",").map(String.init) ?? []
        return includedModuleNames.contains(name)
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
