import UIKit
import SnapKit
import Alamofire

class SignUpFirstVC: UIViewController {
    
    let idTextField = UITextField()
    let passwordTextField = UITextField()
    let nickNameTextField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 배경색 설정
        self.view.backgroundColor = .white
        // 버튼 글자색
        let buttonTitleColor = UIColor(red: 255/255.0, green: 157/255.0, blue: 0/255.0, alpha: 1.0)
        // 버튼 배경색
        let buttonBackgroundColor = UIColor(red: 255/255.0, green: 248/255.0, blue: 238/255.0, alpha: 1.0)
        
        // 안내 메시지 레이블 생성 및 설정
        let signUpGuideMsg = UILabel()
        signUpGuideMsg.text = "아이디와 비밀번호를 입력해주세요"
        signUpGuideMsg.textAlignment = .center
        signUpGuideMsg.font = UIFont.boldSystemFont(ofSize: 18)
        signUpGuideMsg.textColor = .black
        
        // 텍스트 필드 레이블 생성 및 설정
        let idLabel = UILabel()
        idLabel.text = "아이디"
        idLabel.font = UIFont.systemFont(ofSize: 16)
        idLabel.textColor = .darkGray
        
        let passwordLabel = UILabel()
        passwordLabel.text = "비밀번호"
        passwordLabel.font = UIFont.systemFont(ofSize: 16)
        passwordLabel.textColor = .darkGray
        
        let nickNameLabel = UILabel()
        nickNameLabel.text = "닉네임"
        nickNameLabel.font = UIFont.systemFont(ofSize: 16)
        nickNameLabel.textColor = .darkGray
        
        // 텍스트 필드 생성 및 설정
        idTextField.placeholder = "이메일"
        idTextField.borderStyle = .roundedRect
        
        passwordTextField.placeholder = "비밀번호 입력"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        
        nickNameTextField.placeholder = "닉네임 입력"
        nickNameTextField.borderStyle = .roundedRect
        
        // 회원가입 버튼 생성 및 설정
        let signUpButton = UIButton(type: .system)
        signUpButton.setTitle("다음", for: .normal)
        signUpButton.setTitleColor(buttonTitleColor, for: .normal)
        signUpButton.backgroundColor = buttonBackgroundColor
        signUpButton.layer.cornerRadius = 15
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        
        // 뷰에 추가
        self.view.addSubview(signUpGuideMsg)
        self.view.addSubview(idLabel)
        self.view.addSubview(idTextField)
        self.view.addSubview(passwordLabel)
        self.view.addSubview(passwordTextField)
        self.view.addSubview(nickNameLabel)
        self.view.addSubview(nickNameTextField)
        self.view.addSubview(signUpButton)
        
        // 레이아웃 설정
        signUpGuideMsg.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(40)
            $0.centerX.equalTo(self.view)
        }
        
        idLabel.snp.makeConstraints {
            $0.top.equalTo(signUpGuideMsg.snp.bottom).offset(20)
            $0.left.equalTo(idTextField.snp.left)
        }
        
        idTextField.snp.makeConstraints {
            $0.top.equalTo(idLabel.snp.bottom).offset(5)
            $0.centerX.equalTo(self.view)
            $0.width.equalTo(300)
            $0.height.equalTo(40)
        }
        
        passwordLabel.snp.makeConstraints {
            $0.top.equalTo(idTextField.snp.bottom).offset(20)
            $0.left.equalTo(passwordTextField.snp.left)
        }
        
        passwordTextField.snp.makeConstraints {
            $0.top.equalTo(passwordLabel.snp.bottom).offset(5)
            $0.centerX.equalTo(self.view)
            $0.width.equalTo(300)
            $0.height.equalTo(40)
        }
        
        nickNameLabel.snp.makeConstraints {
            $0.top.equalTo(passwordTextField.snp.bottom).offset(20)
            $0.left.equalTo(nickNameTextField.snp.left)
        }
        
        nickNameTextField.snp.makeConstraints {
            $0.top.equalTo(nickNameLabel.snp.bottom).offset(5)
            $0.centerX.equalTo(self.view)
            $0.width.equalTo(300)
            $0.height.equalTo(40)
        }
        
        signUpButton.snp.makeConstraints {
            $0.bottom.equalTo(view.snp.bottom).offset(-40)
            $0.centerX.equalTo(self.view)
            $0.width.equalTo(300)
            $0.height.equalTo(50)
        }
    }
    
    @objc func signUpButtonTapped() {
        guard let email = idTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let nickName = nickNameTextField.text, !nickName.isEmpty else {
            showAlert(message: "모든 필드를 채워주세요.")
            return
        }
        
        // "nickName" 대신 "nickname"을 사용
        let parameters: [String: Any] = ["email": email, "password": password, "nickname": nickName]
        
        // 파라미터 출력 (디버깅용)
        print("Parameters: \(parameters)")
        
        AF.request("http://na2ru2.me:5152/members", method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: SignUpResponse.self) { response in
                switch response.result {
                case .success(let signUpResponse):
                    if let httpResponse = response.response, httpResponse.statusCode == 201 {
                        print("Response JSON: \(signUpResponse)")  // 서버로부터 응답 받은 JSON 출력
                        DispatchQueue.main.async {
                            let signUpSecondVC = SignUpSecondVC()
                            self.navigationController?.pushViewController(signUpSecondVC, animated: true)
                        }
                    }
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let signUpResponse = try JSONDecoder().decode(SignUpResponse.self, from: data)
                            print("Response JSON: \(signUpResponse)")  // 서버로부터 응답 받은 JSON 출력
                            if let validationErrors = signUpResponse.validationErrors {
                                let errors = validationErrors.map { $0.reason }.joined(separator: "\n")
                                DispatchQueue.main.async {
                                    self.showAlert(message: errors)
                                }
                            } else if let message = signUpResponse.message {
                                DispatchQueue.main.async {
                                    self.showAlert(message: message)
                                }
                            }
                        } catch {
                            print("Failed to parse JSON: \(error)")
                            DispatchQueue.main.async {
                                self.showAlert(message: "알 수 없는 에러가 발생했습니다.")
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.showAlert(message: "알 수 없는 에러가 발생했습니다.")
                        }
                    }
                    print(error)
                }
            }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        self.present(alert, animated: true)
    }
}
