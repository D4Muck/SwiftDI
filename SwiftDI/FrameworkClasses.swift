//
// Created by Christoph Muck on 11.02.18.
// Copyright (c) 2018 Christoph Muck. All rights reserved.
//

import Foundation

let types = Types()

struct Type {
    let module: String?
    let initializers: [Method]
    let name: String
    let annotations = [String: NSObject]()
    let variables = [Variable]()
    let methods = [Method]()
    let kind: String
    let implements = [String: Type]()
    let accessLevel: String
}

struct Types {
    let all: [Type] = []
    let classes: [Type] = []
    let protocols: [Type] = []
}

struct Method {
    let accessLevel: String
    let parameters: [Parameter]
    let annotations = [String: NSObject]()
    let shortName: String
    let returnTypeName: TypeName
    let returnType: Type?
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
    let type: Type?
    let annotations = [String: NSObject]()
}
