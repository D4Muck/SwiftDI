//
// Created by Christoph Muck on 11.02.18.
// Copyright (c) 2018 AppFactory GmbH. All rights reserved.
// Factory.swift
//

import Foundation

func lel() {
    getAllFactories().forEach {
        switch $0.creationType {
        case .initializer:
            print("")
        case .storyboard(let name, let id):
            print("")
        }

        for d in $0.dependencies.filter({ $0.injectionType == .property }) {

        }
    }
}
