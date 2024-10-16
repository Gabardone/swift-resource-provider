//
//  Coordinated.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 8/18/24.
//

import Foundation

private actor AsyncProviderCoordinator<ID: Hashable, Value> {
    typealias Parent = AsyncProvider<ID, Value>

    init(parent: Parent) {
        self.parent = parent
    }

    let parent: Parent

    var taskManager = [ID: Task<Value, Never>]()

    fileprivate func taskFor(id: ID) -> Task<Value, Never> {
        taskManager[id] ?? {
            let newTask = Task {
                let result = await parent.valueForID(id)
                taskManager.removeValue(forKey: id)
                return result
            }

            taskManager[id] = newTask
            return newTask
        }()
    }

    // Helper to bridge actor isolation.
    fileprivate nonisolated func valueFor(id: ID) async -> Value {
        return await taskFor(id: id).value
    }
}

public extension AsyncProvider {
    /**
     Ensures that the provider will not do the same work twice when the same id is requested concurrently.

     This modifier doesn't make any other guarantees when it comes to concurrent behavior. You should usually finish
     off an asynchronous provider with this modifier. If handling a synchronous one, use `serialized` instead.
     - Returns: A provider that ensures that multiple overlapping requests for the same `id` use the same task.
     */
    func coordinated() -> AsyncProvider {
        let coordinator = AsyncProviderCoordinator(parent: self)

        return .init { id in
            await coordinator.valueFor(id: id)
        }
    }
}

private actor ThrowingAsyncProviderCoordinator<ID: Hashable, Value> {
    typealias Parent = ThrowingAsyncProvider<ID, Value>

    init(parent: Parent) {
        self.parent = parent
    }

    let parent: Parent

    var taskManager = [ID: Task<Value, Error>]()

    fileprivate func taskFor(id: ID) -> Task<Value, Error> {
        taskManager[id] ?? {
            let newTask = Task { [self] in
                defer {
                    self.taskManager.removeValue(forKey: id)
                }

                return try await parent.valueForID(id)
            }

            taskManager[id] = newTask
            return newTask
        }()
    }

    // Helper to bridge actor isolation.
    fileprivate nonisolated func valueFor(id: ID) async throws -> Value {
        return try await taskFor(id: id).value
    }
}

public extension ThrowingAsyncProvider {
    /**
     Ensures that the provider will not do the same work twice when the same id is requested concurrently.

     This modifier doesn't make any other guarantees when it comes to concurrent behavior. You should usually finish
     off an asynchronous provider with this modifier. If handling a synchronous one, use `serialized` instead.
     - Returns: A provider that ensures that multiple overlapping requests for the same `id` use the same task.
     */
    func coordinated() -> ThrowingAsyncProvider {
        let coordinator = ThrowingAsyncProviderCoordinator(parent: self)

        return .init { id in
            try await coordinator.valueFor(id: id)
        }
    }
}
