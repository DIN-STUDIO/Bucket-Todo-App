import Foundation

struct Bucket: Decodable {
    let bucketId: Int
    let memberId: Int
    let content: String
    let deadLine: String
}

