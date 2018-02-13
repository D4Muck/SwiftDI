//
// Created by Christoph Muck on 11.02.18.
// Copyright (c) 2018 AppFactory GmbH. All rights reserved.
//

import Foundation

let types = Types()

struct Type {
    let initializers: [Method]
    let name: String
    let annotations = [String: NSObject]()
    let variables = [Variable]()
    let methods = [Method]()
}

struct Types {
    let all: [Type] = []
    let classes: [Type] = []
    let protocols: [Type] = []
}

struct Method {
    let parameters: [Parameter]
    let annotations = [String: NSObject]()
    let shortName: String
    let returnTypeName: TypeName
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
