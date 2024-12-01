//
//  Provider.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 4/23/23.
//

import Foundation
import os

/**
 Namespace `enum` for provider building. Declared extensions to it return the root of a provider, then modifiers can be
 applied to them.
 */
public enum Provider {}

extension Provider {
    static let logger = Logger(subsystem: "ResourceProvider", category: "Provider")
}
