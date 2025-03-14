import XCTest
@testable import EmbedKit

final class DocumentTests: XCTestCase {
    func testDocumentInitialization() {
        let id = UUID()
        let text = "Test document text"
        let embedding: [Float] = [0.1, 0.2, 0.3, 0.4]
        
        let document = Document(id: id, text: text, embedding: embedding)
        
        XCTAssertEqual(document.id, id)
        XCTAssertEqual(document.text, text)
        XCTAssertEqual(document.embedding, embedding)
        XCTAssertLessThanOrEqual(document.createdAt.timeIntervalSinceNow, 0)
    }
    
    func testDocumentAutoID() {
        let text = "Test document text"
        let embedding: [Float] = [0.1, 0.2, 0.3, 0.4]
        
        let document = Document(text: text, embedding: embedding)
        
        XCTAssertNotNil(document.id)
        XCTAssertEqual(document.text, text)
        XCTAssertEqual(document.embedding, embedding)
    }
    
    func testDocumentCodable() throws {
        let id = UUID()
        let text = "Test document text"
        let embedding: [Float] = [0.1, 0.2, 0.3, 0.4]
        
        let document = Document(id: id, text: text, embedding: embedding)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(document)
        
        let decoder = JSONDecoder()
        let decodedDocument = try decoder.decode(Document.self, from: data)
        
        XCTAssertEqual(decodedDocument.id, document.id)
        XCTAssertEqual(decodedDocument.text, document.text)
        XCTAssertEqual(decodedDocument.embedding, document.embedding)
        XCTAssertEqual(decodedDocument.createdAt.timeIntervalSince1970, document.createdAt.timeIntervalSince1970, accuracy: 0.001)
    }
    
    func testHybridScore() {
        let document = Document(text: "Test", embedding: [0.1, 0.2])
        
        let vectorScore: Float = 0.8
        let keywordScore: Float = 5.0
        
        // Test with default weight (0.5)
        let hybridScore = document.hybridScore(vectorScore: vectorScore, keywordScore: keywordScore)
        let expectedScore: Float = 0.5 * 0.8 + 0.5 * min(max(5.0 / 10.0, 0), 1) // Vector (0.4) + Keyword (0.5)
        XCTAssertEqual(Double(hybridScore), Double(expectedScore), accuracy: 0.001)
        
        // Test with custom weight (0.7)
        let customWeightScore = document.hybridScore(vectorScore: vectorScore, keywordScore: keywordScore, weight: 0.7)
        let expectedCustomScore: Float = 0.7 * 0.8 + 0.3 * min(max(5.0 / 10.0, 0), 1) // Vector (0.56) + Keyword (0.15)
        XCTAssertEqual(Double(customWeightScore), Double(expectedCustomScore), accuracy: 0.001)
    }
}
