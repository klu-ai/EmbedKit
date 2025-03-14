import Foundation
import MLXEmbedders

public enum SupportedModel: CaseIterable {
    case bge_micro
    case gte_tiny
    case minilm_l6
    case snowflake_xs
    case minilm_l12
    case bge_small
    case multilingual_e5_small
    case bge_base
    case nomic_text_v1
    case nomic_text_v1_5
    case bge_large
    case snowflake_lg
    case bge_m3
    case mixedbread_large

    public var configuration: ModelConfiguration {
        switch self {
        case .bge_micro: return .bge_micro
        case .gte_tiny: return .gte_tiny
        case .minilm_l6: return .minilm_l6
        case .snowflake_xs: return .snowflake_xs
        case .minilm_l12: return .minilm_l12
        case .bge_small: return .bge_small
        case .multilingual_e5_small: return .multilingual_e5_small
        case .bge_base: return .bge_base
        case .nomic_text_v1: return .nomic_text_v1
        case .nomic_text_v1_5: return .nomic_text_v1_5
        case .bge_large: return .bge_large
        case .snowflake_lg: return .snowflake_lg
        case .bge_m3: return .bge_m3
        case .mixedbread_large: return .mixedbread_large
        }
    }

    public var dimension: Int {
        switch self {
        case .bge_micro: return 384
        case .gte_tiny: return 512
        case .minilm_l6: return 384
        case .snowflake_xs: return 384
        case .minilm_l12: return 384
        case .bge_small: return 384
        case .multilingual_e5_small: return 384
        case .bge_base: return 768
        case .nomic_text_v1: return 768
        case .nomic_text_v1_5: return 768
        case .bge_large: return 1024
        case .snowflake_lg: return 1024
        case .bge_m3: return 1024
        case .mixedbread_large: return 1024
        }
    }
}