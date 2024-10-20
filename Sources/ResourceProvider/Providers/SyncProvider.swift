//
//  SyncProvider.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 10/18/24.
//

public protocol SyncProvider<ID, Value, Failure> {
    associatedtype ID: Hashable

    associatedtype Value

    associatedtype Failure: Error

    func valueFor(id: ID) throws(Failure) -> Value
}
