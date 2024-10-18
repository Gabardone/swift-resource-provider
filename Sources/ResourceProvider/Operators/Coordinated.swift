//
//  Coordinated.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 8/18/24.
//

import Foundation

private actor AsyncProviderCoordinator<ID: Hashable & Sendable, Value: Sendable> {
    typealias Parent = AsyncProvider<ID, Value, Never>

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

private actor ThrowingAsyncProviderCoordinator<ID: Hashable & Sendable, Value: Sendable, Failure: Error> {
    typealias Parent = AsyncProvider<ID, Value, Failure>

    init(parent: Parent) {
        self.parent = parent
    }

    let parent: Parent

    var taskManager = [ID: Task<Value, any Error>]()

    fileprivate func taskFor(id: ID) -> Task<Value, any Error> {
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

public extension AsyncProvider where Failure == Never {
    /**
     Ensures that the provider will not do the same work twice when the same id is requested concurrently.

     This modifier doesn't make any other guarantees when it comes to concurrent behavior. You should usually finish
     off an asynchronous provider with this modifier. If handling a synchronous one, use `serialized` instead.
     - Returns: A provider that ensures that multiple overlapping requests for the same `id` use the same task.
     */
    func coordinated() -> Self {
        let coordinator = AsyncProviderCoordinator(parent: self)

        return .init { id in
            await coordinator.valueFor(id: id)
        }
    }
}

public extension AsyncProvider {
    /**
     Ensures that the provider will not do the same work twice when the same id is requested concurrently.

     This modifier doesn't make any other guarantees when it comes to concurrent behavior. You should usually finish
     off an asynchronous provider with this modifier. If handling a synchronous one, use `serialized` instead.
     - TODO: Mention that we're losing typed errors because of `Task` library limitations.
     - Returns: A provider that ensures that multiple overlapping requests for the same `id` use the same task.
     */
    func coordinated() -> AsyncProvider<ID, Value, any Error> {
        let coordinator = ThrowingAsyncProviderCoordinator(parent: self)

        return .init { id in
            try await coordinator.valueFor(id: id)
        }
    }
}
