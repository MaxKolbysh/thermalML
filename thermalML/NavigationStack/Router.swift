//
//  Router.swift
//  thermalML
//
//  Created by Ildar Khabibullin on 26.11.2023.
//

import SwiftUI

final class Router<T: Hashable>: ObservableObject {
    @Published var paths: [T] = []
    private var history: [T] = []
    
    func push(_ path: T) {
        Task { @MainActor in
            guard paths.last != path else { return }
            if let lastPath = paths.last {
                history.append(lastPath)
            }
            paths.append(path)
        }
    }

    func pop() {
        Task { @MainActor in
            if !paths.isEmpty {
                paths.removeLast(1)
            }
            if !history.isEmpty {
                history.removeLast()
            }
        }
    }

    func pop(to: T) {
        Task { @MainActor in
            guard let found = paths.firstIndex(where: { $0 == to }) else { return }
            let numToPop = (found ..< paths.endIndex).count - 1
            paths.removeLast(numToPop)
            if found > 0 {
                history.removeSubrange((found - 1) ..< history.endIndex)
            }
        }
    }

    func popToRoot() {
        Task { @MainActor in
            paths.removeAll()
            history.removeAll()
        }
    }
    
    func popToPrevious() {
        Task { @MainActor in
            guard let previousPath = history.popLast() else { return }
            pop(to: previousPath)
        }
    }
    
    func previousPath() -> T? {
        return history.last
    }
}
