//
// Created by Christoph Muck on 17.02.18.
// Copyright (c) 2018 Christoph Muck. All rights reserved.
//

import Foundation

class Node {

    init(id: String) {
        self.id = id
    }

    let id: String
    var done = false
    var children = [Node]()
    var parents = [Node]()
}

func buildGraph(fromDependencies dependencies: [Dependency]) -> [String: Node] {
    var existingNodes = [String: Node]()

    func getOrCreateNode(withId id: String) -> Node {
        return existingNodes[id] ?? {
            let n = Node(id: id)
            existingNodes[id] = n
            return n
        }()
    }

    dependencies.forEach { d in
        let me = getOrCreateNode(withId: d.typeName)
        d.dependencies.forEach {
            let child = getOrCreateNode(withId: $0.dependency.typeName)
            if !me.children.contains(where: { $0.id == child.id }) {
                me.children.append(child)
                child.parents.append(me)
            }
        }
    }

    return existingNodes
}

func calculateInstantiationOrder(fromGraph: [String: Node]) -> [Node] {
    var graph = fromGraph
    var order = [Node]()
    var unvisited = [Node]()
    var lastCount = -1

    repeat {
        unvisited.append(contentsOf: graph.values.filter { $0.children.filter { !$0.done }.count == 0 })
        while unvisited.count != 0 {
            let currentNode = unvisited.removeFirst()
            order.append(currentNode)
            currentNode.done = true
            graph.removeValue(forKey: currentNode.id)
        }

        let currentCount = graph.values.count
        if (lastCount == currentCount) {
            fatalError("Cycle detected!")
        }
        lastCount = currentCount

    } while (graph.values.count != 0)

    return order
}

func calculateDependencyOrder(forTypeNames requiredTypes: [String], andIncludedModules includedModules: [Module]) -> [Dependency] {
    let dependencies = getDependenciesFromInjectables() + includedModules.flatMap { $0.dependencies }
    let allDependencies = dependencies + getAdditionalDependencies(fromDependencies: dependencies)

    var initialDependencies = allDependencies.filter { requiredTypes.contains($0.typeName) }
    var requiredDependencies = initialDependencies

    func addDependencies(of dependency: Dependency) {
        dependency.dependencies.forEach { dd in
            if let d = allDependencies.first(where: { $0.typeName == dd.dependency.typeName }) {
                if (!requiredDependencies.contains(where: { $0.typeName == d.typeName })) {
                    requiredDependencies.append(d)
                    addDependencies(of: d)
                }
            }
        }
    }

    initialDependencies.forEach { addDependencies(of: $0) }

    let graph = buildGraph(fromDependencies: requiredDependencies)
    let order = calculateInstantiationOrder(fromGraph: graph)

    let dependencyOrder = order.map { node in allDependencies.first(where: { $0.typeName == node.id }) }.flatMap { $0 }
    return dependencyOrder
}
