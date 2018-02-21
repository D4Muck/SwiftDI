//
// Created by Christoph Muck on 17.02.18.
// Copyright (c) 2018 Christoph Muck. All rights reserved.
//

func getAllDependencies() -> [Dependency] {
    return getDependenciesFromInjectables() + getAllModules().flatMap { $0.dependencies }
}
