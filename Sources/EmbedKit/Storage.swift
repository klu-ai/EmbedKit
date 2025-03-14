import Foundation

/// Storage protocol abstracts the persistence layer for Documents.
import Foundation

/// Storage protocol abstracts the persistence layer for Documents.
///
/// It allows for multiple underlying storage implementations (e.g., File-based or SQLite)
/// without changing the higher-level API used in EmbedKit.
public protocol Storage {
    /// Prepares or creates the storage location for documents if needed.
    func createStorageDirectoryIfNeeded() async throws
    
    /// Loads all documents from the storage.
    func loadDocuments() async throws -> [Document]
    
    /// Saves a document.
    ///
    /// - Parameter document: The document to save.
    func saveDocument(_ document: Document) async throws
    
    /// Deletes a document by its unique identifier.
    ///
    /// - Parameter id: The identifier of the document to be deleted.
    func deleteDocument(withID id: UUID) async throws
    
    /// Updates an existing document. The document is replaced or modified as needed.
    ///
    /// - Parameter document: The updated document.
    func updateDocument(_ document: Document) async throws
    
    /// Returns all documents currently stored.
    func getAllDocuments() -> [Document]
    
    /// Retrieves the normalized embedding for a document by its ID.
    ///
    /// - Parameter id: The identifier of the document.
    /// - Returns: The normalized embedding, or nil if not found.
    func getNormalizedEmbedding(for id: UUID) -> [Float]?
    
    /// Resets the storage, removing all documents.
    func reset() async throws
}