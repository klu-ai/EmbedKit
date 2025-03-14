import Foundation
import Accelerate
import MLXEmbedders

@available(macOS 14.0, iOS 17.0, *)
public class EmbedKit: EmbedProtocol {
    private let config: EmbedConfig
    private let embedder: Embedder
    private let storage: Storage

    /// Creates a new EmbedKit instance with specified parameters
    ///
    /// - Parameters:
    ///   - name: The name of the database
    ///   - directoryURL: Optional custom directory for storage
    ///   - dimension: The vector dimension
    ///   - modelConfiguration: The MLX model configuration
    public init(
        name: String,
        directoryURL: URL? = nil,
        dimension: Int = 384,
        modelConfiguration: ModelConfiguration = .nomic_text_v1_5
    ) async throws {
        let config = EmbedConfig(
            name: name,
            directoryURL: directoryURL,
            dimension: dimension
        )
        self.config = config
        self.embedder = try await Embedder(configuration: modelConfiguration)
        let storageDirectory: URL
        if let customStorageDirectory = config.directoryURL {
            storageDirectory = customStorageDirectory.appending(path: config.name)
        } else {
            storageDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("EmbedKit").appendingPathComponent(config.name)
        }
        try FileManager.default.createDirectory(at: storageDirectory, withIntermediateDirectories: true)
        self.storage = try FileStorage(storageDirectory: storageDirectory)
    }

    /// Creates a new EmbedKit instance with a pre-configured EmbedConfig
    ///
    /// - Parameters:
    ///   - config: The configuration options
    ///   - modelConfiguration: The MLX model configuration
    public init(
        config: EmbedConfig,
        modelConfiguration: ModelConfiguration = .nomic_text_v1_5
    ) async throws {
        self.config = config
        self.embedder = try await Embedder(configuration: modelConfiguration)
        let storageDirectory: URL
        if let customStorageDirectory = config.directoryURL {
            storageDirectory = customStorageDirectory.appending(path: config.name)
        } else {
            storageDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("EmbedKit").appendingPathComponent(config.name)
        }
        try FileManager.default.createDirectory(at: storageDirectory, withIntermediateDirectories: true)
        self.storage = try FileStorage(storageDirectory: storageDirectory)
    }

    /// Retrieves all documents in the database
    ///
    /// - Returns: Array of Document objects
    public func getAllDocuments() -> [Document] {
        return storage.getAllDocuments()
    }

    /// Adds multiple documents to the database
    ///
    /// - Parameters:
    ///   - texts: The text contents to add
    ///   - ids: Optional UUIDs
    /// - Returns: The UUIDs of the added documents
    public func addDocuments(texts: [String], ids: [UUID]? = nil) async throws -> [UUID] {
        if let ids = ids, ids.count != texts.count {
            throw EmbedError.invalidInput("Number of IDs must match number of texts")
        }
        let embeddings = await embedder.embed(texts: texts)
        var documentIds = [UUID]()
        for (index, text) in texts.enumerated() {
            let docId = ids?[index] ?? UUID()
            let doc = Document(id: docId, text: text, embedding: embeddings[index])
            try await storage.saveDocument(doc)
            documentIds.append(docId)
        }
        return documentIds
    }

    /// Searches using a precomputed embedding vector
    ///
    /// - Parameters:
    ///   - query: The query embedding
    ///   - numResults: Maximum number of results to return
    ///   - threshold: Minimum similarity threshold
    /// - Returns: Array of search results ordered by similarity
    public func search(query: [Float], numResults: Int? = nil, threshold: Float? = nil) async throws -> [SearchResult] {
        let norm = l2Norm(query)
        var divisorQuery = norm + 1e-9
        var normalizedQuery = [Float](repeating: 0, count: query.count)
        vDSP_vsdiv(query, 1, &divisorQuery, &normalizedQuery, 1, vDSP_Length(query.count))
        var results: [SearchResult] = []
        let docs = storage.getAllDocuments()
        for doc in docs {
            guard let normDoc = storage.getNormalizedEmbedding(for: doc.id) else { continue }
            let similarity = dotProduct(normalizedQuery, normDoc)
            if let minT = threshold ?? config.searchOptions.minThreshold, similarity < minT {
                continue
            }
            results.append(
                SearchResult(
                    id: doc.id,
                    text: doc.text,
                    score: similarity,
                    createdAt: doc.createdAt
                )
            )
        }
        results.sort { $0.score > $1.score }
        let limit = numResults ?? config.searchOptions.defaultNumResults
        return Array(results.prefix(limit))
    }

    /// Searches using text that will be embedded
    ///
    /// - Parameters:
    ///   - query: The text query to search for
    ///   - numResults: Maximum number of results to return
    ///   - threshold: Minimum similarity threshold
    /// - Returns: Array of search results ordered by similarity
    public func searchText(query: String, numResults: Int? = nil, threshold: Float? = nil) async throws -> [SearchResult] {
        let queryEmbedding = try await embedder.embed(text: query)
        return try await search(query: queryEmbedding, numResults: numResults, threshold: threshold)
    }

    /// Deletes documents from the database
    ///
    /// - Parameter ids: The UUIDs of documents to delete
    public func deleteDocuments(ids: [UUID]) async throws {
        for id in ids {
            try await storage.deleteDocument(withID: id)
        }
    }

    /// Updates an existing document with new text
    ///
    /// - Parameters:
    ///   - id: The UUID of the document
    ///   - newText: The new text content
    public func updateDocument(id: UUID, newText: String) async throws {
        let embedding = try await embedder.embed(text: newText)
        let updatedDoc = Document(id: id, text: newText, embedding: embedding)
        try await storage.updateDocument(updatedDoc)
    }

    /// Removes all documents from the database
    public func reset() async throws {
        try await storage.reset()
    }

    /// Generates embeddings for texts without storing them
    ///
    /// - Parameter texts: The texts to embed
    /// - Returns: Array of embedding vectors
    public func embedTexts(_ texts: [String]) async -> [[Float]] {
        return await embedder.embed(texts: texts)
    }

    /// Generates an embedding for a single text without storing it
    ///
    /// - Parameter text: The text to embed
    /// - Returns: Embedding vector
    public func embedText(_ text: String) async throws -> [Float] {
        return try await embedder.embed(text: text)
    }

    // MARK: - Private Helper Methods

    private func dotProduct(_ a: [Float], _ b: [Float]) -> Float {
        var result: Float = 0
        vDSP_dotpr(a, 1, b, 1, &result, vDSP_Length(a.count))
        return result
    }

    private func l2Norm(_ v: [Float]) -> Float {
        var sumSquares: Float = 0
        vDSP_svesq(v, 1, &sumSquares, vDSP_Length(v.count))
        return sqrt(sumSquares)
    }
}