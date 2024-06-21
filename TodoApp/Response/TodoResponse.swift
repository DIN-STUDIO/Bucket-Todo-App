import Foundation

//struct TodoResponse: Decodable {
//    let message: String
//    let response: [Todo]
//}
struct TodoResponse: Codable {
    let message: String
    let response: [Todo]
}

struct Todo: Codable {
    let todoId: Int
    let content: String
    let deadLine: String
    let completed: Bool
    let memberId: Int
    let createdTime: String
    let modifiedTime: String
}

