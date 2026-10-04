//
//  Env.swift
//  laMyl
//
//  Loads environment variables from .env file
//

import Foundation

enum Env {
    private static var values: [String: String] = {
        load()
    }()

    /// Load .env file from bundle or project root
    private static func load() -> [String: String] {
        var result: [String: String] = [:]

        // Get the source file path (works during development)
        let sourceFile = #file
        let sourceDir = (sourceFile as NSString).deletingLastPathComponent
        let projectRoot = (sourceDir as NSString).deletingLastPathComponent

        // Try multiple possible locations for .env file
        let possiblePaths = [
            // 1. In bundle resources (for production builds)
            Bundle.main.path(forResource: ".env", ofType: nil),
            Bundle.main.path(forResource: "env", ofType: ""),

            // 2. Project root (for development - relative to source file)
            projectRoot + "/.env",

            // 3. Relative to app bundle (for development builds)
            Bundle.main.bundlePath + "/../../../.env",
            Bundle.main.bundlePath + "/../../../../.env",
            Bundle.main.bundlePath + "/../../../../../.env",

            // 4. Current working directory
            FileManager.default.currentDirectoryPath + "/.env",

            // 5. Absolute path (fallback for known location)
            "/Users/akashi/Downloads/laMyl/.env"
        ].compactMap { $0 }

        for path in possiblePaths {
            if FileManager.default.fileExists(atPath: path),
               let contents = try? String(contentsOfFile: path, encoding: .utf8) {
                result = parse(contents)
                print("[Env] Loaded .env from: \(path)")
                break
            }
        }

        if result.isEmpty {
            print("[Env] Warning: No .env file found. Searched paths:")
            for path in possiblePaths {
                let exists = FileManager.default.fileExists(atPath: path)
                print("  - \(path) (exists: \(exists))")
            }
        }

        return result
    }

    /// Parse .env file contents
    private static func parse(_ contents: String) -> [String: String] {
        var result: [String: String] = [:]

        let lines = contents.components(separatedBy: .newlines)
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // Skip empty lines and comments
            if trimmed.isEmpty || trimmed.hasPrefix("#") {
                continue
            }

            // Split by first '=' only
            if let equalIndex = trimmed.firstIndex(of: "=") {
                let key = String(trimmed[..<equalIndex]).trimmingCharacters(in: .whitespaces)
                let value = String(trimmed[trimmed.index(after: equalIndex)...])
                    .trimmingCharacters(in: .whitespaces)
                    .trimmingCharacters(in: CharacterSet(charactersIn: "\"'")) // Remove quotes

                if !key.isEmpty {
                    result[key] = value
                }
            }
        }

        return result
    }

    /// Get a required environment variable (crashes if not found)
    static func require(_ key: String) -> String {
        guard let value = values[key], !value.isEmpty else {
            fatalError("[Env] Missing required environment variable: \(key). Make sure .env file exists and contains this key.")
        }
        return value
    }

    /// Get an optional environment variable
    static func get(_ key: String) -> String? {
        let value = values[key]
        return (value?.isEmpty == true) ? nil : value
    }

    /// Get environment variable with default value
    static func get(_ key: String, default defaultValue: String) -> String {
        get(key) ?? defaultValue
    }

    /// Reload environment variables (useful for testing)
    static func reload() {
        values = load()
    }
}
