import ArgumentParser
import EmbedKit
import Foundation

@main
struct EmbedCLI: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "embed",
        abstract: "A command-line tool for working with EmbedKit",
        subcommands: [Add.self, Search.self, List.self, Delete.self, Reset.self],
        defaultSubcommand: List.self
    )
    
    struct Options: ParsableArguments {
        @Option(name: .shortAndLong, help: "Database name")
        var db: String = "default"
        
        @Option(name: .long, help: "Custom storage directory")
        var dir: String?
        
        func getDirectoryURL() -> URL? {
            if let dir = dir {
                return URL(fileURLWithPath: dir)
            }
            return nil
        }
    }
    
    struct Add: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Add documents to the database"
        )
        
        @OptionGroup var options: Options
        
        @Option(name: .shortAndLong, help: "Text to add")
        var text: String
        
        func run() async throws {
            let embedKit = try await EmbedKit(
                name: options.db,
                directoryURL: options.getDirectoryURL()
            )
            
            let id = try await embedKit.addDocument(text: text)
            print("Added document with ID: \(id)")
        }
    }
    
    struct Search: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Search for similar documents"
        )
        
        @OptionGroup var options: Options
        
        @Option(name: .shortAndLong, help: "Query text")
        var query: String
        
        @Option(name: .shortAndLong, help: "Number of results")
        var limit: Int = 5
        
        @Option(name: .shortAndLong, help: "Minimum similarity threshold (0-1)")
        var threshold: Float?
        
        func run() async throws {
            let embedKit = try await EmbedKit(
                name: options.db,
                directoryURL: options.getDirectoryURL()
            )
            
            let results = try await embedKit.searchText(
                query: query,
                numResults: limit,
                threshold: threshold
            )
            
            if results.isEmpty {
                print("No results found.")
                return
            }
            
            print("Found \(results.count) results:")
            for (i, result) in results.enumerated() {
                print("\n[\(i+1)] Score: \(String(format: "%.4f", result.score))")
                print("ID: \(result.id)")
                print("Text: \(result.text)")
            }
        }
    }
    
    struct List: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "List all documents in the database"
        )
        
        @OptionGroup var options: Options
        
        func run() async throws {
            let embedKit = try await EmbedKit(
                name: options.db,
                directoryURL: options.getDirectoryURL()
            )
            
            let docs = embedKit.getAllDocuments()
            
            if docs.isEmpty {
                print("No documents found in database '\(options.db)'")
                return
            }
            
            print("Found \(docs.count) documents in database '\(options.db)':")
            for (i, doc) in docs.enumerated() {
                print("\n[\(i+1)] ID: \(doc.id)")
                print("Text: \(doc.text)")
                print("Created: \(doc.createdAt)")
            }
        }
    }
    
    struct Delete: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Delete documents by ID"
        )
        
        @OptionGroup var options: Options
        
        @Option(name: .shortAndLong, help: "Document ID to delete")
        var id: String
        
        func run() async throws {
            let embedKit = try await EmbedKit(
                name: options.db,
                directoryURL: options.getDirectoryURL()
            )
            
            guard let docId = UUID(uuidString: id) else {
                throw ValidationError("Invalid UUID format")
            }
            
            try await embedKit.deleteDocuments(ids: [docId])
            print("Deleted document with ID: \(docId)")
        }
    }
    
    struct Reset: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Remove all documents from the database"
        )
        
        @OptionGroup var options: Options
        
        @Flag(name: .shortAndLong, help: "Confirm reset without prompting")
        var yes = false
        
        func run() async throws {
            if !yes {
                print("Are you sure you want to reset the database '\(options.db)'? This action cannot be undone.")
                print("Type 'yes' to continue:")
                
                let response = readLine()?.lowercased()
                if response != "yes" {
                    print("Reset cancelled.")
                    return
                }
            }
            
            let embedKit = try await EmbedKit(
                name: options.db,
                directoryURL: options.getDirectoryURL()
            )
            
            try await embedKit.reset()
            print("Database '\(options.db)' has been reset.")
        }
    }
}