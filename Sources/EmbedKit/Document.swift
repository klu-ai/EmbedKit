import Foundation

/// A document stored in the vector database.
public struct Document: Identifiable, Codable, Sendable {
    /// The unique identifier of the document.
    public let id: UUID
    
    /// The text content of the document.
    public let text: String
    
    /// The vector embedding of the document.
    public let embedding: [Float]
    
    /// The timestamp when the document was created.
    public let createdAt: Date

    /// Creates a new document with the given properties.
    /// - Parameters:
    ///   - id: The unique identifier for the document. If nil, a new UUID will be generated.
    ///   - text: The text content of the document.
    ///   - embedding: The vector embedding of the document.
    public init(id: UUID? = nil, text: String, embedding: [Float]) {
        self.id = id ?? UUID()
        self.text = text
        self.embedding = embedding
        self.createdAt = Date()
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, text, embedding, createdAt
    }
}