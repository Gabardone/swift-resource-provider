//
//  Coordinated.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 8/18/24.
//

import Foundation

private actor AsyncProviderCoordinator<
    Coordinated: AsyncProvider
> where Coordinated.Failure == Never, Coordinated.ID: Sendable, Coordinated.Value: Sendable {
    typealias ID = Coordinated.ID

    typealias Value = Coordinated.Value

    init(coordinated: Coordinated) {
        self.coordinated = coordinated
    }

    let coordinated: Coordinated

    var taskManager = [ID: Task<Value, Never>]()

    fileprivate func taskFor(id: ID) -> Task<Value, Never> {
        taskManager[id] ?? {
            let newTask = Task {
                let result = await coordinated.value(for: id)
                taskManager.removeValue(forKey: id)
                return result
            }

            taskManager[id] = newTask
            return newTask
        }()
    }
}

extension AsyncProviderCoordinator: AsyncProvider {
    nonisolated
    func value(for id: Coordinated.ID) async -> Coordinated.Value {
        await taskFor(id: id).value
    }
}

private actor ThrowingAsyncProviderCoordinator<
    Coordinated: AsyncProvider
> where Coordinated.ID: Sendable, Coordinated.Value: Sendable {
    typealias ID = Coordinated.ID

    typealias Value = Coordinated.Value

    init(coordinated: Coordinated) {
        self.coordinated = coordinated
    }

    let coordinated: Coordinated

    var taskManager = [ID: Task<Value, any Error>]()

    fileprivate func taskFor(id: ID) -> Task<Value, any Error> {
        taskManager[id] ?? {
            let newTask = Task { [self] in
                defer {
                    self.taskManager.removeValue(forKey: id)
                }

                return try await coordinated.value(for: id)
            }

            taskManager[id] = newTask
            return newTask
        }()
    }
}

extension ThrowingAsyncProviderCoordinator: AsyncProvider {
    typealias Failure = any Error // Cannot do better with `Task`

    nonisolated
    func value(for id: Coordinated.ID) async throws -> Coordinated.Value {
        return try await taskFor(id: id).value
    }
}

public extension AsyncProvider where Failure == Never, ID: Sendable, Value: Sendable {
    /**
     Ensures that the provider will not do the same work twice when the same id is requested concurrently.

     This modifier doesn't make any other guarantees when it comes to concurrent behavior. You should usually finish
     off an asynchronous provider with this modifier. If handling a synchronous one, use `serialized` instead.
     - Returns: A provider that ensures that multiple overlapping requests for the same `id` use the same task.
     */
    func coordinated() -> some AsyncProvider<ID, Value, Never> {
        AsyncProviderCoordinator(coordinated: self)
    }
}

public extension AsyncProvider where ID: Sendable, Value: Sendable{
    /**
     Ensures that the provider will not do the same work twice when the same id is requested concurrently.

     This modifier doesn't make any other guarantees when it comes to concurrent behavior. You should usually finish
     off an asynchronous provider with this modifier. If handling a synchronous one, use `serialized` instead.
     - TODO: Mention that we're losing typed errors because of `Task` library limitations.
     - Returns: A provider that ensures that multiple overlapping requests for the same `id` use the same task.
     */
    func coordinated() -> some AsyncProvider<ID, Value, any Error> {
        ThrowingAsyncProviderCoordinator(coordinated: self)
    }
}
