//
// Created by Christoph Muck on 19.02.18.
// Copyright (c) 2018 Christoph Muck. All rights reserved.
//

func trait(fromAnnotations annotations: [String: Any]) -> Trait {
    if let scopeName = annotations["Scope"] as? String {
        return .scoped(scopeName: scopeName)
    }
    return .unscoped
}
