//
//  BehaviorTree.swift
//  CartoonWars
//
//  Created by Josue Rosales on 6/27/26.
//

enum NodeResult {
    case success, failure
}

typealias Node = () -> NodeResult

func condition(_ predicat: @escaping @autoclosure () -> Bool) -> Node {
    return {
        return predicat() ? .success : .failure
    }
}

// Needs only 1 to pass
func selector(nodes: [Node]) -> Node {
    return  {
        for node in nodes {
            let result = node()
            if result == .success {
                return result
            }
        }
        return .failure
    }
}

// Need all to pass to say pass
func sequence(nodes: [Node]) -> Node {
    return {
        guard nodes.isEmpty == false else { return .failure }
        for node in nodes {
            let result = node()
            if result == .failure {
                return result
            }
        }
        return .success
    }
}
