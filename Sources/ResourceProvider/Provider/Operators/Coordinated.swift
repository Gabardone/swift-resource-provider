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
    nonisolated
    func value(for id: Coordinated.ID) async throws(Coordinated.Failure) -> Coordinated.Value {
        // A bit of a song and dance to work around `Swift.Task` lack of support for typed throws.
        do {
            return try await taskFor(id: id).value
        } catch let error as Coordinated.Failure {
            throw error
        } catch {
            // We should definitely never find ourselves here.
            fatalError()
        }
    }
}

public extension AsyncProvider where Failure == Never, ID: Sendable, Value: Sendable {
    /**
     Ensures that the provider will not do the same work twice when the same id is requested concurrently. Non-throwing
     version.

     Finishing off an ``AsyncProvider`` with this operator unloads the responsibility of ensuring that work is not
     repeated for several concurrent requests for the same resource from all the others.
     - Note: Non-throwing and throwing versions of this exist because of `Swift.Task`'s current limitations around
     generic typed throws.
     - Returns: A provider that ensures that multiple overlapping requests for the same `id` use the same task.
     */
    func coordinated() -> some AsyncProvider<ID, Value, Never> {
        AsyncProviderCoordinator(coordinated: self)
    }
}

public extension AsyncProvider where ID: Sendable, Value: Sendable {
    /**
     Ensures that the provider will not do the same work twice when the same id is requested concurrently. Throwing
     version.

     Finishing off an ``AsyncProvider`` with this operator unloads the responsibility of ensuring that work is not
     repeated for several concurrent requests for the same resource from all the others.
     - Note: Non-throwing and throwing versions of this exist because of `Swift.Task`'s current limitations around
     generic typed throws.
     - Returns: A provider that ensures that multiple overlapping requests for the same `id` use the same task.
     */
    func coordinated() -> some AsyncProvider<ID, Value, Failure> {
        ThrowingAsyncProviderCoordinator(coordinated: self)
    }
}
