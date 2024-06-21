import Foundation

struct BucketResponse: Decodable {
    let message: String
    let response: Bucket?
}
