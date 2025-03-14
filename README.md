# EmbedKit

## On-Device Vector Database for Swift Applications

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platforms: macOS | iOS](https://img.shields.io/badge/Platforms-macOS%20%7C%20iOS-blueviolet)](https://swift.org/package-manager/)

EmbedKit is a Swift package designed to bring on-device vector database capabilities to Apple platforms, including macOS and iOS. It empowers developers to integrate sophisticated features like semantic search, recommendation engines, and similarity analysis directly within their applications. By operating locally on the device, EmbedKit prioritizes user data privacy and ensures high performance without the need for external services.

Built upon Apple's MLX framework and MLXEmbedders, EmbedKit simplifies the process of generating embeddings and conducting rapid similarity searches on-device. This package is ideally suited for applications that require embedded search functionalities, intelligent content discovery, or any feature that can benefit from understanding textual relationships. EmbedKit provides a comprehensive set of tools for effectively and seamlessly integrating these advanced capabilities into your Swift projects.

## Key Features

*   **Privacy-Focused Local Operation:** Operates entirely on the device, ensuring user data privacy and reducing latency by keeping vector embeddings and search operations local.
*   **Optimized for Apple Silicon:** Engineered to harness the power of Apple silicon using the MLX framework and MLXEmbedders for efficient computation.
*   **Versatile Search Methods:** Supports vector similarity search for semantic understanding and BM25 keyword search for relevance-based retrieval. Hybrid search combines both methods for improved search accuracy.
*   **Efficient Data Management:** Supports batch processing for quick indexing of large datasets and efficient management of real-time content updates.
*   **Persistent Data Storage:** Automatically handles database persistence, ensuring data is saved and consistently available across application sessions.
*   **Extensive Customization Options:** Offers a range of configuration settings to fine-tune search behavior, including adjustable similarity thresholds, result limits, and hybrid search weights.
*   **Flexible Storage Configuration:** Allows users to specify a custom directory for database files, providing control over data management and organization.
*   **Command-Line Interface (CLI):** Includes `EmbedCLI`, a command-line tool for database administration, testing, and integration into development workflows and automated scripts.
*   **Broad Model Compatibility:** Integrates with MLXEmbedders, providing access to a wide selection of pre-trained embedding models to accommodate various language requirements and performance needs.
*   **Modular Design:** Features a clear and modular architecture, enhancing maintainability, scalability, and developer understanding.

## Models Supported

*   **BGE Base:** 768-dimensional embeddings
*   **BGE Large:** 1024-dimensional embeddings
*   **BGE M3:** 1024-dimensional embeddings
*   **BGE Micro:** 384-dimensional embeddings
*   **BGE Small:** 384-dimensional embeddings
*   **GTE Tiny:** 512-dimensional embeddings
*   **MiniLM L12:** 384-dimensional embeddings
*   **MiniLM L6:** 384-dimensional embeddings
*   **MixedBread Large:** 1024-dimensional embeddings
*   **Multilingual E5 Small:** 384-dimensional embeddings
*   **Nomic Text v1:** 768-dimensional embeddings
*   **Nomic Text v1.5:** 768-dimensional embeddings
*   **Snowflake LG:** 1024-dimensional embeddings
*   **Snowflake XS:** 384-dimensional embeddings

For detailed implementation information on supported models, please refer to `Sources/EmbedKit/SupportedModel.swift`. Model support is dependent on the MLX Embedders framework.

## Supported Platforms

*   macOS 14.0+
*   iOS 17.0+

## Installation

EmbedKit can be easily integrated into your Swift projects using the Swift Package Manager.

### Swift Package Manager

**Using Xcode:**

```md
https://github.com/klu-ai/EmbedKit.git
```

1.  Open your Xcode project.
2.  Navigate to `File` in the menu bar, then select `Add Packages...`.
3.  In the search bar, enter the repository URL: `https://github.com/klu-ai/EmbedKit.git` and select the `main` branch.
4.  Choose the `EmbedKit` package and ensure it is added to the appropriate targets within your project.

**Using `Package.swift`:**

To include EmbedKit in your Swift Package Manager project, add the following dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/klu-ai/EmbedKit.git", branch: "main"),
],
```

## Dependencies

EmbedKit utilizes the following Swift packages, which are automatically handled by Swift Package Manager:

*   **[swift-argument-parser](https://github.com/apple/swift-argument-parser.git):**  Provides the foundation for the command-line interface (`EmbedCLI`), offering a user-friendly and robust system for command parsing.
*   **[mlx-swift-examples](https://github.com/ml-explore/mlx-swift-examples/):**  Offers a collection of examples using MLX and includes `MLXEmbedders`, the framework utilized by EmbedKit for generating text embeddings.
*   **[mlx](https://github.com/ml-explore/mlx-swift):** (Transitive dependency) Apple's Machine Learning eXchange framework, serving as the core computational engine for EmbedKit, optimized for Apple silicon.

## Usage

The following examples demonstrate how to use EmbedKit to integrate intelligent features into your Swift applications.

### Basic Setup

1.  **Import EmbedKit:**

    Begin by importing the `EmbedKit` module at the start of your Swift file:

    ```swift
    import EmbedKit
    ```

2.  **Initialize EmbedKit:**

    Create an instance of `EmbedKit`, specifying a database name, vector dimension, and embedding model configuration.

    ```swift
    import Foundation
    import EmbedKit
    import MLXEmbedders

    let embedKit = try await EmbedKit(
        name: "my-content-db",          // Database name
        directoryURL: nil,              // Optional: Custom storage URL (defaults to documents directory)
        dimension: 768,                 // Vector dimension (e.g., 768 for nomic_text_v1_5)
        modelConfiguration: .nomic_text_v1_5 // Embedding model configuration
    )
    ```

3.  **Add Documents:**

    Index your textual data by adding documents. EmbedKit will automatically generate embeddings for the provided text content.

    ```swift
    let documents = [
        "EmbedKit is designed for ease of use.",
        "Develop on-device vector databases with Swift.",
        "Integrate semantic search into your iOS applications."
    ]
    let documentIds = try await embedKit.addDocuments(texts: documents)
    print("Indexed documents with IDs: \(documentIds)")
    ```

4.  **Perform Semantic Search:**

    Execute a semantic search to find documents that are semantically similar to a given query.

    ```swift
    let searchQuery = "swift vector database"
    let searchResults = try await embedKit.searchText(
        query: searchQuery,
        numResults: 3,         // Limit results to 3 (optional, default is 10)
        threshold: 0.7         // Minimum similarity score threshold (optional)
    )

    if searchResults.isEmpty {
        print("No relevant documents found for: '\(searchQuery)'")
    } else {
        print("Search results for '\(searchQuery)':")
        for result in searchResults {
            print("\n- Document ID: \(result.id)")
            print("  Text: \(result.text)")
            print("  Similarity Score: \(String(format: "%.4f", result.score))")
            print("  Created At: \(result.createdAt)")
        }
    }
    ```

5.  **Document Management:**

    Manage your database content by updating, deleting, or resetting documents as needed.

    ```swift
    // Update document text
    if let firstDocumentId = documentIds.first {
        try await embedKit.updateDocument(id: firstDocumentId, newText: "EmbedKit is easy to use and integrate!")
        print("Document updated with ID: \(firstDocumentId)")
    }

    // Delete documents by IDs
    try await embedKit.deleteDocuments(ids: documentIds)
    print("Documents deleted with IDs: \(documentIds)")

    // Reset the database (remove all documents)
    try await embedKit.reset()
    print("Database reset completed.")
    ```

6.  **Direct Embedding Generation:**

    Generate embedding vectors directly without database storage for real-time applications or preprocessing tasks.

    ```swift
    // Generate embedding for text
    let embedding = try await embedKit.embedText("Generate vector embedding.")
    print("Generated embedding vector: \(embedding.prefix(5)) ...") // Display first 5 dimensions

    // Generate embeddings for batch of texts
    let textBatch = ["Text sample A", "Text sample B", "Text sample C"]
    let embeddingsBatch = await embedKit.embedTexts(textBatch)
    print("Generated embeddings for \(textBatch.count) texts.")
    ```

7.  **Model Selection:**

    EmbedKit, in conjunction with [MLXEmbedders](https://github.com/ml-explore/mlx-swift-examples), supports a variety of pre-trained embedding models. Select a model during `EmbedKit` initialization based on your application's performance and resource requirements.

    ```swift
    import EmbedKit
    import MLXEmbedders

    // List available embedding models and dimensions
    print("Available Embedding Models:")
    for model in SupportedModel.allCases {
        print("- Model: \(model), Dimension: \(model.dimension)")
    }

    // Initialize EmbedKit with 'bge_small' model for size and performance balance
    let embedKitBgeSmall = try await EmbedKit(
        name: "my-bge-db",
        dimension: SupportedModel.bge_small.dimension,
        modelConfiguration: SupportedModel.bge_small.configuration
    )
    print("EmbedKit initialized with '\(SupportedModel.bge_small)' model.")
    ```

    For a comprehensive list of supported models and their specifications, please refer to `Sources/EmbedKit/SupportedModel.swift`.

## Command Line Tool (EmbedCLI)

EmbedKit includes `EmbedCLI`, a command-line interface designed for database management and automation. After building the `EmbedCLI` target in Xcode or using `swift build`, the `embed` command will be available in the `.build/debug` or `.build/release` directory. For convenient access, add this directory to your system's `PATH` environment variable.

**Available Commands:**

```bash
embed <command> [options]
```

*   **`add`**: Adds a new document to the database.
    ```bash
    embed add --db my-database --text "Document content."
    ```
*   **`search`**: Searches for documents similar to a query.
    ```bash
    embed search --db my-database --query "Search query" --limit 5 --threshold 0.7
    ```
*   **`list`**: Lists all documents currently in the database.
    ```bash
    embed list --db my-database
    ```
*   **`delete`**: Deletes a specific document by its UUID.
    ```bash
    embed delete --db my-database --id <document-uuid>
    ```
*   **`reset`**: Resets the database, removing all documents. Requires user confirmation.
    ```bash
    embed reset --db my-database
    embed reset --db my-database --yes # Force reset without confirmation
    ```

**Common Options:**

*   `--db <database_name>`: Specifies the database name. Defaults to `default`.
*   `--dir <directory_path>`: Specifies a custom directory path for database storage.

## Architecture Overview

EmbedKit is built with a modular architecture to ensure clarity and maintainability. Key components include:

*   **`EmbedKit` (Class):** The primary class that provides the API for interacting with the vector database. It manages core operations including embedding generation, storage, and search functionalities, and implements the `EmbedProtocol`.
*   **`Document` (Struct):** Represents a document within the database, encapsulating its unique ID, text content, vector embedding, and creation timestamp.
*   **`Embedder` (Class):** Responsible for managing embedding generation using MLXEmbedders. It handles model loading and the process of generating embeddings from text.
*   **`Storage` (Protocol):** Defines the interface for data persistence, allowing for different storage mechanisms to be implemented.
*   **`FileStorage` (Class):** An implementation of the `Storage` protocol that uses the file system and JSON files for persistent document storage.
*   **`Config` (Struct):** Encapsulates configuration parameters for `EmbedKit`, including the database name, storage directory, vector dimension, and search settings.
*   **`SearchResult` (Struct):** Represents a single search result, containing the document ID, text, similarity score, and creation date.
*   **`Index` (Struct):** Provides BM25 keyword indexing and search capabilities, utilized for hybrid search strategies.
*   **`EmbedCLI` (Command-Line Tool):** A command-line interface built using `swift-argument-parser` for database management and scripting purposes.

## License

EmbedKit is released under the **MIT License**. For complete license details, please refer to the [LICENSE](LICENSE) file.

## Contributing

Contributions to EmbedKit are highly encouraged. To contribute, please fork the repository and submit a pull request with your proposed enhancements or bug fixes.

**Building and Testing:**

To build and test EmbedKit locally, use the provided `build.sh` script or SwiftPM commands directly:

```bash
swift build
swift test
```

For more advanced build options, execute `./build.sh --help` to view available flags.

Thank you for exploring EmbedKit. We are excited to see how you utilize EmbedKit to develop innovative on-device applications with semantic understanding and intelligent features.