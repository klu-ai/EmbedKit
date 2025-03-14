import XCTest
@testable import EmbedKit

final class IndexTests: XCTestCase {
    
    var documents: [Document] = []
    
    override func setUp() {
        super.setUp()
        
        documents = [
            Document(id: UUID(), text: "Apple introduces new iPhone model", embedding: [0.1, 0.2, 0.3]),
            Document(id: UUID(), text: "Scientists discover new planet in solar system", embedding: [0.2, 0.3, 0.4]),
            Document(id: UUID(), text: "Global warming effects on polar ice caps", embedding: [0.3, 0.4, 0.5]),
            Document(id: UUID(), text: "New machine learning model outperforms GPT-4", embedding: [0.4, 0.5, 0.6]),
            Document(id: UUID(), text: "Apple releases update for macOS", embedding: [0.5, 0.6, 0.7])
        ]
    }
    
    func testBM25Search() {
        let index = Index(documents: documents)
        
        // Search for "Apple"
        let appleResults = index.search(query: "Apple", topK: 3)
        
        // We should find some documents with "Apple" in them
        XCTAssertGreaterThan(appleResults.count, 0)
        
        let appleTexts = appleResults.map { $0.document.text }
        
        // Verify content of returned documents
        for text in appleTexts {
            // Verify each retrieved document actually includes "Apple"
            XCTAssertTrue(text.contains("Apple"))
        }
        
        // If we got multiple results, make sure they're in descending order by score
        if appleResults.count > 1 {
            for i in 0..<appleResults.count-1 {
                XCTAssertGreaterThanOrEqual(appleResults[i].score, appleResults[i+1].score)
            }
        }
    }
    
    func testAddDocument() {
        var index = Index(documents: documents)
        let initialCount = index.search(query: "technology", topK: 10).count
        
        // Add a new document with "technology" term
        let newDoc = Document(
            id: UUID(),
            text: "New technology innovations in renewable energy",
            embedding: [0.6, 0.7, 0.8]
        )
        index.addDocument(newDoc)
        
        // Search again for "technology"
        let updatedCount = index.search(query: "technology", topK: 10).count
        
        // Should have one more result
        XCTAssertEqual(updatedCount, initialCount + 1)
        
        // Ensure the new document is found
        let results = index.search(query: "renewable energy", topK: 3)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].document.id, newDoc.id)
    }
    
    func testEmptyQuery() {
        let index = Index(documents: documents)
        let results = index.search(query: "", topK: 5)
        
        // Empty query should return no results
        XCTAssertEqual(results.count, 0)
    }
    
    func testNoRelevantResults() {
        let index = Index(documents: documents)
        let results = index.search(query: "xylophone quantum entanglement", topK: 5)
        
        // No document contains these terms, so should have no results
        XCTAssertEqual(results.count, 0)
    }
}
