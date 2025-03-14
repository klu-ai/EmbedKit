import Foundation
import MLX
import MLXEmbedders

@available(macOS 14.0, iOS 17.0, tvOS 17.0, visionOS 1.0, watchOS 10.0, *)
public class Embedder {
    
  private let modelContainer: ModelContainer
  private let configuration: ModelConfiguration

  public init(configuration: ModelConfiguration = .nomic_text_v1_5) async throws {
      self.configuration = configuration
      try await Self.ensureModelWeightsExist(for: configuration)
      self.modelContainer = try await MLXEmbedders.loadModelContainer(configuration: configuration)
  }

  private static func ensureModelWeightsExist(for configuration: ModelConfiguration) async throws {
      let modelDirectory = configuration.modelDirectory()
      if !FileManager.default.fileExists(atPath: modelDirectory.path) {
          print("Model weights not found at \(modelDirectory.path). Creating model directory...")
          try FileManager.default.createDirectory(at: modelDirectory, withIntermediateDirectories: true)
          print("Model directory created at \(modelDirectory.path)")
          throw EmbedError.embeddingFailed("Weights directory created but weights are missing. Please ensure \(configuration.id) weights are downloaded to \(modelDirectory.path).")
      } else {
          // Check if directory is empty or weights are invalid
          let contents = try FileManager.default.contentsOfDirectory(atPath: modelDirectory.path)
          if contents.isEmpty {
              throw EmbedError.embeddingFailed("Model directory \(modelDirectory.path) exists but is empty. Please download weights for \(configuration.id).")
          }
      }
  }

  public func embed(texts: [String]) async -> [[Float]] {
    await modelContainer.perform { (model: EmbeddingModel, tokenizer, pooling) -> [[Float]] in
      let inputs = texts.map {
        tokenizer.encode(text: $0, addSpecialTokens: true)
      }

      // Pad to longest
      let maxLength = inputs.reduce(into: 16) { acc, elem in
        acc = max(acc, elem.count)
      }

      let padded = stacked(
        inputs.map { elem in
          MLXArray(
            elem
              + Array(
                repeating: tokenizer.eosTokenId ?? 0,
                count: maxLength - elem.count))
        })

      let mask = (padded .!= tokenizer.eosTokenId ?? 0)
      let tokenTypes = MLXArray.zeros(like: padded)

      let result = pooling(
        model(padded, positionIds: nil, tokenTypeIds: tokenTypes, attentionMask: mask),
        normalize: true, applyLayerNorm: true
      )

      return result.map { $0.asArray(Float.self) }
    }
  }

  public func embed(text: String) async throws -> [Float] {
    let embeddings = await embed(texts: [text])
    return embeddings[0]
  }
}