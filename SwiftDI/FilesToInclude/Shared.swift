//
// Created by Christoph Muck on 11.02.18.
// Copyright (c) 2018 AppFactory GmbH. All rights reserved.
// Shared.swift
//

import Foundation

enum InjectionType {
    case initializer, property
}

struct Dependency: CustomStringConvertible {
    let name: String
    let dependencyTypeName: String
    var lowercasedDependencyTypeName: String {
        return dependencyTypeName.prefix(1).lowercased() + dependencyTypeName.dropFirst()
    }
    let injectionType: InjectionType
    let isProvider: Bool

    var description: String {
        return name.description + ", " + dependencyTypeName.description + ", " + isProvider.description
    }
}

enum CreationType {
    case initializer, storyboard(name: String, id: String)
}

struct Factory {
    let typeName: String
    let creationType: CreationType
    let dependencies: [Dependency]
}

class DependencyResolver {
    func getDependencies(ofType: Type) -> [Dependency] {
        fatalError("Please override me!")
    }

    func createDependency(name: String, dependencyTypeName: String, injectionType: InjectionType) -> Dependency {
        var cleanedTypeName = removeLastCharIfNeeded(dependencyTypeName)
        let isProvider = cleanedTypeName.starts(with: "Provider<")

        if (isProvider) {
            cleanedTypeName = extractGenericTypeName(from: cleanedTypeName)
        }

        return Dependency(name: name,
                dependencyTypeName: cleanedTypeName,
                injectionType: injectionType,
                isProvider: isProvider)
    }

    func extractGenericTypeName(from text: String) -> String {
        var results = [String]()

        var regex: NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: ".*<(.*)>", options: [])
        } catch {
            fatalError("Regex errror")
        }

        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))

        guard let match = matches.first else { fatalError("Regex errror") }

        let lastRangeIndex = match.numberOfRanges - 1
        guard lastRangeIndex >= 1 else { fatalError("Regex errror") }

        for i in 1...lastRangeIndex {
            let capturedGroupIndex = match.range(at: i)
            let matchedString = (text as NSString).substring(with: capturedGroupIndex)
            results.append(matchedString)
        }

        return results.first!
    }

    private func removeLastCharIfNeeded(_ string: String) -> String {
        if "!?".contains(string.last!) {
            return string.substring(to: string.index(before: string.endIndex))
        }
        return string
    }
}

class InitializerDependencyResolver: DependencyResolver {
    override func getDependencies(ofType type: Type) -> [Dependency] {
        return type.initializers.first?.parameters.map {
            createDependency(name: $0.name, dependencyTypeName: $0.typeName.name, injectionType: .initializer)
        } ?? []
    }
}

class PropertyDependencyResolver: DependencyResolver {
    override func getDependencies(ofType type: Type) -> [Dependency] {
        return type.variables.filter { $0.annotations.keys.contains("Inject") }
                .map {
                    createDependency(name: $0.name, dependencyTypeName: $0.typeName.name, injectionType: .property)
                }
    }
}

class CompositeDependencyResolver: DependencyResolver {

    let resolvers: [DependencyResolver]

    init(resolvers: [DependencyResolver]) {
        self.resolvers = resolvers
    }

    override func getDependencies(ofType type: Type) -> [Dependency] {
        return resolvers.flatMap { $0.getDependencies(ofType: type) }
    }
}

func getAllFactories() -> [Factory] {
    return types.all.filter { $0.annotations.keys.contains("Injectable") }.map { type -> Factory in
        let creationType: CreationType
        let dependencyResolver: DependencyResolver
        if type.annotations.keys.contains("FromStoryboard") {
            creationType = .storyboard(
                    name: type.annotations["StoryboardName"] as! String,
                    id: type.annotations["StoryboardIdentifier"] as! String
            )
            dependencyResolver = PropertyDependencyResolver()
        } else {
            creationType = .initializer
            dependencyResolver = CompositeDependencyResolver(
                    resolvers: [
                        InitializerDependencyResolver(),
                        PropertyDependencyResolver()
                    ]
            )
        }
        return Factory(typeName: type.name, creationType: creationType, dependencies: dependencyResolver.getDependencies(ofType: type))
    }
}
