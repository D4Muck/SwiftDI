//
// Created by Christoph Muck on 17.02.18.
// Copyright (c) 2018 Christoph Muck. All rights reserved.
//

func getModulesToImportForFile(withModule module: String, containingFactories factories: [Factory]) -> [String] {
    return getModulesToImportForFile(withModule: module, containingModules: factories.flatMap {
        $0.dependency.dependencies.map { $0.dependency.module }
    })
}

func getModulesToImportForFile(withModule module: String, containingComponents components: [Component]) -> [String] {
    return getModulesToImportForFile(withModule: module, containingModules: components.flatMap {
        $0.modules.map { $0.module } + $0.order.map { $0.module }
    })
}

func getModulesToImportForFile(withModule module: String, containingComponentBuilders componentBuilders: [ComponentBuilder]) -> [String] {
    return getModulesToImportForFile(withModule: module, containingModules: componentBuilders.flatMap {
        $0.modules.map { $0.module }
    })
}

func getModulesToImportForFile(withModule module: String, containingModules modules: [String]) -> [String] {
    return Set(modules).filter { $0.count != 0 && $0 != module }
}

