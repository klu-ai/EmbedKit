# EmbedKit

EmbedKit is a Swift-based vector database designed for on-device applications, enabling advanced user experiences through local vector storage and retrieval. Built on Apple's MLX framework, **EmbedKit** provides fast, efficient embedding generation and similarity search capabilities for macOS and iOS applications.

## Key Features

- **On-Device Storage:** Stores and manages vector embeddings locally, enhancing privacy and reducing latency
- **MLX Integration:** Leverages Apple's MLX framework for high-performance embedding generation
- **Hybrid Search:** Combines vector similarity with BM25 text search for comprehensive and relevant results
- **Batch Processing:** Indexes documents in parallel for faster data ingestion
- **Persistent Storage:** Automatically saves and loads document data, preserving database state across sessions
- **Configurable Search:** Customizes search behavior with adjustable thresholds, result limits, and hybrid weights
- **Custom Storage Location:** Specifies custom directory for database storage
- **CLI Tool:** Includes a command-line interface for database management, testing, and debugging

## Supported Platforms

- macOS 14.0 or later
- iOS 17.0 or later
- tvOS 17.0 or later
- visionOS 1.0 or later
- watchOS 10.0 or later

## Installation

### Swift Package Manager

To integrate EmbedKit into your project using Swift Package Manager, add the following dependency in your `Package.swift` file:
```swift
dependencies: [
    .package(url: "https://github.com/klu-ai/EmbedKit.git", branch: "main"),
],
```

### Dependencies

EmbedKit relies on the following Swift packages:

- [mlx-swift-examples](https://github.com/ml-explore/mlx-swift-examples): Provides MLX-based embeddings
- [swift-argument-parser](https://github.com/apple/swift-argument-parser): Used for the command-line interface

## Usage

### Basic Usage

1. **Import EmbedKit**

   ```swift
   import EmbedKit
   ```

2. **Create Database**

   ```swift
   import Foundation
   import EmbedKit
   import MLXEmbedders

   let embedKit = try await EmbedKit(
       name: "my-vector-db",
       directoryURL: nil,  // Optional custom storage location
       dimension: 768,     // Matches the nomic_text_v1_5 model dimension
       modelConfiguration: .nomic_text_v1_5
   )
   ```

3. **Add Documents**

   ```swift
   let texts = [
       "First document text",
       "Second document text",
       "Third document text"
   ]
   let documentIds = try await embedKit.addDocuments(texts: texts)
   ```

4. **Search Documents**

   ```swift
   let results = try await embedKit.searchText(
       query: "search query",
       numResults: 5,      // Optional
       threshold: 0.8      // Optional
   )

   for result in results {
       print("Document ID: \(result.id)")
       print("Text: \(result.text)")
       print("Similarity Score: \(result.score)")
       print("Created At: \(result.createdAt)")
   }
   ```

5. **Document Management**

   ```swift
   // Update document
   try await embedKit.updateDocument(id: documentId, newText: "Updated text")
   
   // Delete documents
   try await embedKit.deleteDocuments(ids: [documentId1, documentId2])
   
   // Reset database
   try await embedKit.reset()
   ```

6. **Generate Embeddings Only**

   ```swift
   // Generate embedding without storing
   let embedding = try await embedKit.embedText("Text to embed")
   
   // Generate multiple embeddings
   let embeddings = await embedKit.embedTexts(["First text", "Second text"])
   ```


7. **Model Selection**

   ```swift
   import EmbedKit

   // List all supported models
   for model in SupportedModel.allCases {
       print("Model: \(model), Dimension: \(model.dimension)")
   }

   // Initialize EmbedKit with a supported model
   let selectedModel = SupportedModel.nomic_text_v1_5
   let embedKit = try await EmbedKit(
       name: "my-db",
       dimension: selectedModel.dimension,
       modelConfiguration: selectedModel.configuration
   )
   ```


## Command Line Tool

EmbedKit includes a command-line interface for managing databases:

```bash
# List all documents
embed list --db my-database

# Add a document
embed add --text "Document content" --db my-database

# Search for similar documents
embed search --query "Search query" --db my-database --limit 5

# Delete a document
embed delete --id <document-uuid> --db my-database

# Reset a database
embed reset --db my-database
```

## Architecture

EmbedKit is a single module that integrates all necessary components for vector database functionality, including data structures, storage, embedding generation, and search capabilities.

## License

EmbedKit is released under the MIT License. See the [LICENSE](LICENSE) file for more information.

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request with your improvements.

To build and test the project, use the following commands:

```bash
swift build
swift test
```
