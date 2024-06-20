import Foundation

struct UserInfoResponse: Decodable {
    let message: String
    let response: UserInfo?
}
