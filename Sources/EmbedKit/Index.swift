import Foundation

private func tokenize(_ text: String) -> [String] {
    text.lowercased()
        .folding(options: .diacriticInsensitive, locale: .current)
        .components(separatedBy: CharacterSet.alphanumerics.inverted)
        .filter { !$0.isEmpty }
}

/// An index for BM25-based keyword search over Documents
public struct Index {
    private let k1: Float
    private let b: Float
    private var documents: [Document]
    private var documentFrequencies: [String: Int]
    private var documentLengths: [UUID: Int]
    private var averageDocumentLength: Float
    
    /// Creates a new BM25 index for the given documents
    ///
    /// - Parameters:
    ///   - documents: The documents to index
    ///   - k1: BM25 k1 parameter (default: 1.2)
    ///   - b: BM25 b parameter (default: 0.75)
    public init(documents: [Document], k1: Float = 1.2, b: Float = 0.75) {
        self.k1 = k1
        self.b = b
        self.documents = documents
        self.documentFrequencies = [:]
        
        self.documentLengths = documents.reduce(into: [:]) { dict, doc in
            dict[doc.id] = tokenize(doc.text).count
        }
        
        self.averageDocumentLength = Float(documentLengths.values.reduce(0, +)) / Float(documents.count)
        
        for document in documents {
            let terms = Set(tokenize(document.text))
            for term in terms {
                documentFrequencies[term, default: 0] += 1
            }
        }
    }
    
    /// Searches the index using BM25 scoring
    ///
    /// - Parameters:
    ///   - query: The search query
    ///   - topK: Maximum number of results to return
    /// - Returns: Array of tuples containing documents and their BM25 scores
    public func search(query: String, topK: Int = 10) -> [(document: Document, score: Float)] {
        let queryTerms = tokenize(query)
        var scores: [(Document, Float)] = []
        
        for document in documents {
            let docLength = Float(documentLengths[document.id] ?? 0)
            var score: Float = 0.0
            
            for term in queryTerms {
                let tf = termFrequency(term: term, in: document)
                let df = Float(documentFrequencies[term] ?? 0)
                
                let idf = log((Float(documents.count) - df + 0.5) / (df + 0.5))
                let numerator = tf * (k1 + 1)
                let denominator = tf + k1 * (1 - b + b * docLength / averageDocumentLength)
                
                score += idf * (numerator / denominator)
            }
            
            scores.append((document, score))
        }
        
        return scores
            .sorted { $0.1 > $1.1 }
            .prefix(topK)
            .filter { $0.1 > 0 }
    }
    
    /// Add a new document to the index
    ///
    /// - Parameter document: The document to add
    public mutating func addDocument(_ document: Document) {
        documents.append(document)
        
        let length = tokenize(document.text).count
        documentLengths[document.id] = length
        
        let terms = Set(tokenize(document.text))
        for term in terms {
            documentFrequencies[term, default: 0] += 1
        }
        
        let totalLength = documentLengths.values.reduce(0, +)
        self.averageDocumentLength = Float(totalLength) / Float(documents.count)
    }
    
    private func termFrequency(term: String, in document: Document) -> Float {
        Float(
            tokenize(document.text)
                .filter { $0 == term }
                .count)
    }
}

extension Document {
    /// Calculates a hybrid search score combining vector similarity and keyword relevance
    ///
    /// - Parameters:
    ///   - vectorScore: The vector similarity score
    ///   - keywordScore: The keyword relevance score from BM25
    ///   - weight: Weight for vector score (0.0-1.0), keyword weight will be (1-weight)
    /// - Returns: Combined score
    public func hybridScore(vectorScore: Float, keywordScore: Float, weight: Float = 0.5) -> Float {
        let normalizedKeywordScore = min(max(keywordScore / 10.0, 0), 1)
        return weight * vectorScore + (1 - weight) * normalizedKeywordScore
    }
}
