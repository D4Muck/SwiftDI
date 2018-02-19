//
// Created by Christoph Muck on 17.02.18.
// Copyright (c) 2018 Christoph Muck. All rights reserved.
//

struct Module {
    let name: String
    let module: String
    let type: Type?

    init(name: String, module: String, type: Type?) {
        self.name = name
        self.module = module
        self.type = type
    }

    init(name: String, module: String) {
        self.init(name: name, module: module, type: nil)
    }

    var lowercasedName: String {
        return name.prefix(1).lowercased() + name.dropFirst()
    }

    var accessLevel: String {
        return type?.accessLevel ?? ""
    }
}

func getAllModules() -> [Module] {
    return types.classes.filter { $0.annotations.keys.contains("Module") }.flatMap { type -> Module in
        return Module(name: type.name, module: type.module!, type: type)
    }
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
