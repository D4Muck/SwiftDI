//
// Created by Christoph Muck on 17.02.18.
// Copyright (c) 2018 Christoph Muck. All rights reserved.
//

import Foundation

class DependencyResolver {

    let types: Types
    let implementingTypeCalculator: ImplementingTypeCalculator

    init(types: Types) {
        self.types = types
        self.implementingTypeCalculator = ImplementingTypeCalculator(types: types)
    }

    func getDependencies(ofType: Type) -> [DependencyDeclaration] {
        fatalError("Please override me!")
    }

    func createDependency(
            name: String,
            declaredTypeName: String,
            declaredType: Type?,
            injectionMethod: InjectMethod
    ) -> DependencyDeclaration {
        var cleanedTypeName = removeLastCharIfNeeded(declaredTypeName)
        let isProvider = cleanedTypeName.starts(with: "Provider<")

        var cleanedDeclaredType = declaredType
        if (isProvider) {
            cleanedTypeName = extractGenericTypeName(from: cleanedTypeName)
            cleanedDeclaredType = types.all.filter { $0.name == cleanedTypeName }.first
        }

        let implementingType = implementingTypeCalculator.getImplementingType(forType: cleanedDeclaredType)

        let dependency = Dependency(
                typeName: implementingType?.name ?? declaredTypeName,
                type: implementingType,
                module: implementingType?.module ?? "",

                //Don't about last three when generating factories
                dependencies: [],
                createdBy: .initializer,
                trait: .normal
        )

        return DependencyDeclaration(
                name: name,
                dependency: dependency,
                injectMethod: injectionMethod,
                isProvider: isProvider,
                declaredTypeName: cleanedTypeName,
                declaredType: cleanedDeclaredType
        )
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
    override func getDependencies(ofType type: Type) -> [DependencyDeclaration] {
        return type.initializers.first?.parameters.map {
            createDependency(name: $0.name, declaredTypeName: $0.typeName.name, declaredType: $0.type, injectionMethod: .initializer)
        } ?? []
    }
}

class PropertyDependencyResolver: DependencyResolver {
    override func getDependencies(ofType type: Type) -> [DependencyDeclaration] {
        return type.variables.filter { $0.annotations.keys.contains("Inject") }
                .map {
                    createDependency(name: $0.name, declaredTypeName: $0.typeName.name, declaredType: $0.type, injectionMethod: .property)
                }
    }
}

class CompositeDependencyResolver: DependencyResolver {

    let resolvers: [DependencyResolver]

    init(types: Types, resolvers: [DependencyResolver]) {
        self.resolvers = resolvers
        super.init(types: types)
    }

    override func getDependencies(ofType type: Type) -> [DependencyDeclaration] {
        return resolvers.flatMap { $0.getDependencies(ofType: type) }
    }
}
