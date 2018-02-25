//
// Created by Christoph Muck on 11.02.18.
// Copyright (c) 2018 Christoph Muck. All rights reserved.
//

import Foundation

let types = Types()

public enum AccessLevel: String {
    case `internal` = "internal"
    case `private` = "private"
    case `fileprivate` = "fileprivate"
    case `public` = "public"
    case `open` = "open"
    case none = ""
}

struct Type {
    let module: String? = ""
    let initializers: [Method] = []
    let name: String = ""
    let localName: String = ""
    let annotations = [String: NSObject]()
    let variables = [Variable]()
    let methods = [Method]()
    let kind: String = ""
    let implements = [String: Type]()
    let accessLevel: String = ""

    public init(name: String = "",
                parent: Type? = nil,
                accessLevel: AccessLevel = .internal,
                isExtension: Bool = false,
                variables: [Variable] = [],
                methods: [Method] = [],
                subscripts: [Subscript] = [],
                inheritedTypes: [String] = [],
                containedTypes: [Type] = [],
                typealiases: [Typealias] = [],
                attributes: [String: Attribute] = [:],
                annotations: [String: NSObject] = [:],
                isGeneric: Bool = false) {
    }
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

struct Subscript {
}

struct Attribute {
}

struct Typealias {
}
