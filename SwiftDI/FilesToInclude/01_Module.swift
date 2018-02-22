//
// Created by Christoph Muck on 17.02.18.
// Copyright (c) 2018 Christoph Muck. All rights reserved.
//

struct Module {
    let name: String
    let module: String
    let type: Type?
    let dependencies: [Dependency]
    let declaredSubcomponents: [String]

    init(name: String, module: String, dependencies: [Dependency], type: Type?, declaredSubcomponents: [String]) {
        self.name = name
        self.module = module
        self.type = type
        self.dependencies = dependencies
        self.declaredSubcomponents = declaredSubcomponents
    }

    init(name: String, module: String, dependencies: [Dependency]) {
        self.init(name: name, module: module, dependencies: dependencies, type: nil, declaredSubcomponents: [])
    }

    var lowercasedName: String {
        return name.prefix(1).lowercased() + name.dropFirst()
    }

    var accessLevel: String {
        return type?.accessLevel ?? ""
    }
}
