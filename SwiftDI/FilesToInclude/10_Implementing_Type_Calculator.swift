//
// Created by Christoph Muck on 17.02.18.
// Copyright (c) 2018 Christoph Muck. All rights reserved.
//

import Foundation

class ImplementingTypeCalculator {

    let types: Types

    init(types: Types) {
        self.types = types
    }

    func getImplementingType(forType type: Type?) -> Type? {
        guard let type = type else { return nil }
        guard type.kind == "protocol" else { return type }
        guard let implementingType = types.classes.filter({ $0.implements.keys.contains(type.name) }).first else {
            fatalError("No implementing type found!")
        }
        return implementingType
    }
}
