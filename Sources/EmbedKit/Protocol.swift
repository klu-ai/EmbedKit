import Foundation

/// A protocol defining the requirements for a vector database instance.
public protocol EmbedProtocol {

    /// Adds multiple documents to the vector store in batch.
    ///
    /// - Parameters:
    ///   - texts: The text contents of the documents.
    ///   - ids: Optional unique identifiers for the documents.
    /// - Returns: The IDs of the added documents.
    func addDocuments(
        texts: [String],
        ids: [UUID]?
    ) async throws -> [UUID]

    /// Searches for similar documents using a *pre-computed query embedding*.
    ///
    /// - Parameters:
    ///   - query: The query vector to search with.
    ///   - numResults: Maximum number of results to return.
    ///   - threshold: Minimum similarity threshold.
    /// - Returns: An array of search results ordered by similarity.
    func search(
        query: [Float],
        numResults: Int?,
        threshold: Float?
    ) async throws -> [SearchResult]

    /// Removes all documents from the vector store.
    func reset() async throws
}

// MARK: - Default Implementations

public extension EmbedProtocol {

    /// Adds a document to the vector store by embedding text.
    ///
    /// - Parameters:
    ///   - text: The text content of the document.
    ///   - id: Optional unique identifier for the document.
    /// - Returns: The ID of the added document.
    func addDocument(
        text: String,
        id: UUID? = nil
    ) async throws -> UUID {
        let ids = try await addDocuments(
            texts: [text],
            ids: id.map { [$0] }
        )
        return ids[0]
    }
}