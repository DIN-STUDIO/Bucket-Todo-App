import Foundation

struct ValidationError: Decodable {
    let field: String
    let value: String?
    let reason: String
}
