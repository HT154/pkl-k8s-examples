//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the Pkl project authors. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//===----------------------------------------------------------------------===//
import PklSwift

public enum AppConfig {}

extension AppConfig {
    public enum Mode: String, CaseIterable, CodingKeyRepresentable, Decodable, Hashable, Sendable {
        case development = "development"
        case production = "production"
    }

    public struct Module: PklRegisteredType, Decodable, Hashable, Sendable {
        public static let registeredIdentifier: String = "AppConfig"

        /// Application runtime mode.
        public var mode: Mode

        /// Application listen port.
        public var port: UInt16

        /// Application database configuration.
        public var database: Database

        public init(mode: Mode, port: UInt16, database: Database) {
            self.mode = mode
            self.port = port
            self.database = database
        }
    }

    public struct Database: PklRegisteredType, Decodable, Hashable, Sendable {
        public static let registeredIdentifier: String = "AppConfig#Database"

        public var name: String

        public var host: String

        public var port: UInt16

        public var username: String?

        public var password: String?

        public init(name: String, host: String, port: UInt16, username: String?, password: String?) {
            self.name = name
            self.host = host
            self.port = port
            self.username = username
            self.password = password
        }
    }

    /// Load the Pkl module at the given source and evaluate it into `AppConfig.Module`.
    ///
    /// - Parameter source: The source of the Pkl module.
    public static func loadFrom(source: ModuleSource) async throws -> AppConfig.Module {
        try await PklSwift.withEvaluator { evaluator in
            try await loadFrom(evaluator: evaluator, source: source)
        }
    }

    /// Load the Pkl module at the given source and evaluate it with the given evaluator into
    /// `AppConfig.Module`.
    ///
    /// - Parameter evaluator: The evaluator to use for evaluation.
    /// - Parameter source: The module to evaluate.
    public static func loadFrom(
        evaluator: PklSwift.Evaluator,
        source: PklSwift.ModuleSource
    ) async throws -> AppConfig.Module {
        try await evaluator.evaluateModule(source: source, as: Module.self)
    }
}