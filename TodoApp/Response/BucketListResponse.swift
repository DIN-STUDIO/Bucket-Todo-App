import Foundation

struct BucketListResponse: Decodable {
    let message: String
    let response: [Bucket]?
}
