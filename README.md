# EmbedKit

## On-Device Vector Database for Swift Applications

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platforms: macOS | iOS | tvOS | visionOS | watchOS](https://img.shields.io/badge/Platforms-macOS%20%7C%20iOS%20%7C%20tvOS%20%7C%20visionOS%20%7C%20watchOS-blueviolet)](https://swift.org/package-manager/)

EmbedKit is a Swift package designed to provide on-device vector database capabilities for Apple platforms, including macOS, iOS, tvOS, visionOS, and watchOS. It enables developers to integrate functionalities such as semantic search, recommendation systems, and similarity analysis directly into their applications. By operating locally on the device, EmbedKit prioritizes user privacy and ensures efficient performance.

Utilizing Apple's MLX framework and MLXEmbedders, EmbedKit facilitates the generation of embeddings and the execution of rapid similarity searches on-device. This package is suitable for applications that require embedded search functionalities, intelligent content discovery, or any feature that benefits from understanding textual similarity without reliance on external services. EmbedKit delivers a comprehensive set of tools for integrating these advanced capabilities into your Swift projects effectively and seamlessly.

## Key Features

*   **Privacy-Focused Local Operation:** Executes entirely on the device, ensuring user data privacy and minimizing latency by keeping vector embeddings and search operations local.
*   **Optimized for Apple Silicon:** Built to leverage the performance of Apple silicon through the utilization of the MLX framework and MLXEmbedders.
*   **Versatile Search Methods:** Supports vector similarity search for semantic understanding and BM25 keyword search for relevance-based retrieval. Hybrid search combines both methods for enhanced results.
*   **Efficient Data Management:** Supports batch processing for rapid indexing of large datasets and efficient handling of real-time content updates.
*   **Persistent Data Storage:** Manages database persistence automatically, ensuring data is saved and loaded across application sessions for consistent user experience.
*   **Extensive Customization Options:** Offers a range of configuration settings to fine-tune search behavior, including adjustable similarity thresholds, result limits, and hybrid search weights.
*   **Flexible Storage Configuration:** Allows specification of a custom directory for database files, providing control over data management and organization.
*   **Command-Line Interface (CLI):** Includes `EmbedCLI`, a command-line tool for database administration, testing, and integration into development workflows and automated scripts.
*   **Broad Model Compatibility:** Integrates with MLXEmbedders, providing access to a diverse selection of pre-trained embedding models to suit various language requirements and performance needs.
*   **Modular Design:** Features a clear and modular architecture, enhancing maintainability, scalability, and developer understanding.

## Supported Platforms

*   macOS 14.0+
*   iOS 17.0+
*   tvOS 17.0+
*   visionOS 1.0+
*   watchOS 10.0+

## Installation

EmbedKit can be integrated into your Swift projects using the Swift Package Manager.

### Swift Package Manager

**Using Xcode:**

1.  Open your Xcode project.
2.  Navigate to `File` in the menu bar, then select `Add Packages...`.
3.  In the search bar, enter the repository URL: `https://github.com/klu-ai/EmbedKit.git` and select the `main` branch.
4.  Select the `EmbedKit` package and ensure it is added to the appropriate targets in your project.

**Using `Package.swift`:**

To incorporate EmbedKit into your Swift Package Manager project, add the following dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/klu-ai/EmbedKit.git", branch: "main"),
],
```

### Dependencies

EmbedKit utilizes the following Swift packages, which are automatically managed by Swift Package Manager:

*   **[swift-argument-parser](https://github.com/apple/swift-argument-parser.git):** Provides the foundation for the command-line interface (`EmbedCLI`), facilitating the creation of a user-friendly and robust command parsing system.
*   **[mlx-swift-examples](https://github.com/ml-explore/mlx-swift-examples/):** Offers a collection of examples using MLX and includes `MLXEmbedders`, the framework used by EmbedKit for generating text embeddings.
*   **[mlx](https://github.com/ml-explore/mlx-swift):** (Transitive dependency) Apple's Machine Learning eXchange framework, serving as the core numerical computation engine for EmbedKit, optimized for Apple silicon.

## Usage

The following examples demonstrate how to use EmbedKit to add intelligent features to your Swift applications.

### Basic Setup

1.  **Import EmbedKit:**

    Import the `EmbedKit` module at the beginning of your Swift file:

    ```swift
    import EmbedKit
    ```

2.  **Initialize EmbedKit:**

    Instantiate `EmbedKit`, specifying a database name, vector dimension, and embedding model configuration.

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

    Execute a semantic search to find documents similar to a given query.

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

    Refer to `Sources/EmbedKit/SupportedModel.swift` for a comprehensive list of supported models and their specifications.

## Command Line Tool (EmbedCLI)

EmbedKit includes `EmbedCLI`, a command-line interface for database management and automation. After building the `EmbedCLI` target in Xcode or using `swift build`, the `embed` command is available in the `.build/debug` or `.build/release` directory. For convenient access, add this directory to your system's `PATH` environment variable.

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

EmbedKit is designed with a modular architecture to promote clarity and maintainability. Key components include:

*   **`EmbedKit` (Class):** The primary class providing the API for interacting with the vector database. It manages core operations including embedding generation, storage, and search functionalities. Implements the `EmbedProtocol`.
*   **`Document` (Struct):** Represents a document within the database, encapsulating its unique ID, text content, vector embedding, and creation timestamp.
*   **`Embedder` (Class):** Responsible for handling embedding generation using MLXEmbedders. Manages model loading and the process of generating embeddings from text.
*   **`Storage` (Protocol):** Defines the interface for data persistence, allowing for different storage mechanisms to be implemented.
*   **`FileStorage` (Class):** An implementation of the `Storage` protocol using the file system and JSON files for persistent document storage.
*   **`Config` (Struct):** Encapsulates configuration parameters for `EmbedKit`, including the database name, storage directory, vector dimension, and search settings.
*   **`SearchResult` (Struct):** Represents a single search result, containing the document ID, text, similarity score, and creation date.
*   **`Index` (Struct):** Provides BM25 keyword indexing and search capabilities, utilized for hybrid search strategies.
*   **`EmbedCLI` (Command-Line Tool):** A command-line interface built using `swift-argument-parser` for database management and scripting purposes.

## License

EmbedKit is released under the **MIT License**. For complete license details, refer to the [LICENSE](LICENSE) file.

## Contributing

Contributions to EmbedKit are welcomed. To contribute, please fork the repository and submit a pull request with your proposed enhancements or bug fixes.

**Building and Testing:**

To build and test EmbedKit locally, use the provided `build.sh` script or SwiftPM commands directly:

```bash
swift build
swift test
```

For more advanced build options, execute `./build.sh --help` to view available flags.

Thank you for exploring EmbedKit. We look forward to seeing how you use EmbedKit to build innovative on-device applications with semantic understanding and intelligent features.