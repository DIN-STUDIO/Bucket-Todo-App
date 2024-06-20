import Foundation

struct SignUpResponse: Decodable {
    let message: String?
    let validationErrors: [ValidationError]?
}
