import Foundation

struct LoginResponse: Decodable {
    let message: String?
    let validationErrors: [ValidationError]?
}
