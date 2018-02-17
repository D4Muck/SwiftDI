//
// Created by Christoph Muck on 17.02.18.
// Copyright (c) 2018 Christoph Muck. All rights reserved.
//

func getAllFactories() -> [Factory] {
    return getAllDependencies().map { Factory(dependency: $0) }
}

func getModulesToImportForFile(withModule module: String, containingFactories factories: [Factory]) -> [String] {
    return Array(factories.reduce(into: Set<String>()) { set, factory in
        factory.dependency.dependencies.map { $0.dependency.module }.forEach { set.insert($0) }
    }).filter { $0.count != 0 && $0 != module }
}

func getAllFactoriesSeparatedByModule() -> [String: [Factory]] {
    return getAllFactories().reduce(into: [String: [Factory]]()) { dict, element in
        var factories: [Factory]
        if let arr = dict[element.module] {
            factories = arr
        } else {
            factories = [Factory]()
        }
        factories.append(element)
        dict[element.module] = factories
    }
}
