//
// Created by Christoph Muck on 11.02.18.
// Copyright (c) 2018 AppFactory GmbH. All rights reserved.
//

import Foundation

let types = All(all: [])

struct Type {
    let initializers: [Method]
    let name: String
    let annotations = [String: NSObject]()
    let variables = [Variable]()
}

struct All {
    let all: [Type]
}

struct Method {
    let parameters: [Parameter]
}

struct Parameter {
    let typeName: TypeName
    let name: String
    let type: Type?
}

struct TypeName {
    let name: String
}

struct Variable {
    let name: String
    let typeName: TypeName
    let annotations = [String: NSObject]()
}
