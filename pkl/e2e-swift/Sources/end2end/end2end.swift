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
import Foundation
import PklSwift

// This file implements a fake web application
// It loads its configuration from the path specified via the first CLI arg
//   * If the path ends in ".pkl", it will be loaded via the Pkl evaluator
//   * Otherwise, it will be loaded as pkl-binary data
// Loaded configuration is printed to the console
// Then the application sleeps forever

@main
struct end2end {
    static func main() async throws {
        guard let configPath = CommandLine.arguments.dropFirst().first else {
            throw Err.invalidUsage
        }

        let config: AppConfig.Module
        if configPath.hasSuffix(".pkl") {
            print("Loading configuration from \(configPath) using Pkl evaluator")
            config = try await AppConfig.loadFrom(source: .path(configPath))
        } else {
            print("Loading configuration from \(configPath) as pkl-binary")
            let configData = try Data(contentsOf: URL(filePath: configPath))
            config = try PklDecoder.decode(AppConfig.Module.self, from: [UInt8](configData))
        }

        print("\nConfiguration loaded:")
        print("\tMode: \(config.mode)")
        print("\tPort: \(config.port)")
        print("\tDatabase URL: \(config.database.asURL)")

        print("\nPress ctrl-C to exit...")
        while true {
            try await Task.sleep(nanoseconds: 1_000_000_000_000)
        }
    }

    enum Err: Error {
        case invalidUsage
    }
}

extension AppConfig.Database {
    var asURL: String {
        if let username, let password {
            "db://\(username):\(password)@\(host):\(port)/\(name)"
        } else {
            "db://\(host):\(port)/\(name)"
        }
    }
}
