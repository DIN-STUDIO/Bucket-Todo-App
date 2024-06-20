import UIKit
import Alamofire

class MyBucketVC: UIViewController {
    let nicknameLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        // 버튼 색 : FF9D00    255,157,0
        // 00님 배경색 : FFF8EE 255,248,238
        // 상세 투두 배경색 : F6F6F6   246,246,246
        // 폰트 컬러 : 흰색
        
        let buttonTitleColor = UIColor(red: 255/255.0, green: 157/255.0, blue: 0/255.0, alpha: 1.0)
        let buttonBackgroundColor = UIColor(red: 255/255.0, green: 248/255.0, blue: 238/255.0, alpha: 1.0)
        
        // 사용자 정보 불러오기
        fetchUserInfo()
    }
    
    func fetchUserInfo() {
        guard let jwtToken = UserDefaults.standard.string(forKey: "jwtToken") else {
            print("JWT 토큰이 없습니다.")
            self.title = "My 버킷 투두"
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(jwtToken)"
        ]
        
        AF.request("http://na2ru2.me:5152/members", method: .get, headers: headers)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: UserInfoResponse.self) { response in
                switch response.result {
                case .success(let userInfoResponse):
                    guard let userInfo = userInfoResponse.response else {
                        DispatchQueue.main.async {
                            self.title = "My 버킷 투두"
                        }
                        return
                    }
                    let memberId = userInfo.memberId
                    let email = userInfo.email
                    let nickname = userInfo.nickname
                    
                    print("Member ID: \(memberId)")
                    print("Email: \(email)")
                    print("Nickname: \(nickname)")
                    
                    DispatchQueue.main.async {
                        self.title = "\(nickname)님의 버킷 투두리스트"
                    }
                case .failure(let error):
                    print("Error fetching user info: \(error)")
                    DispatchQueue.main.async {
                        self.title = "My 버킷 투두"
                    }
                }
            }
    }
}
