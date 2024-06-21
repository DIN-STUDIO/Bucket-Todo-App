import UIKit
import SnapKit
import Alamofire

class SignInVC: UIViewController {
    
    let idTextField = UITextField()
    let passwordTextField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 배경색 설정
        self.view.backgroundColor = .white
        // 버튼 글자색
        let buttonTitleColor = UIColor(red: 255/255.0, green: 157/255.0, blue: 0/255.0, alpha: 1.0)
        // 버튼 배경색
        let buttonBackgroundColor = UIColor(red: 255/255.0, green: 248/255.0, blue: 238/255.0, alpha: 1.0)
        
        // 텍스트 필드 생성 및 설정
        idTextField.placeholder = "이메일"
        idTextField.borderStyle = .roundedRect
        
        passwordTextField.placeholder = "비밀번호"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        
        // 로그인 버튼 생성 및 설정
        let signInButton = UIButton(type: .system)
        signInButton.setTitle("로그인하기", for: .normal)
        signInButton.setTitleColor(buttonTitleColor, for: .normal)
        signInButton.backgroundColor = buttonBackgroundColor
        signInButton.layer.cornerRadius = 15
        signInButton.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
        
        // 뷰에 추가
        self.view.addSubview(idTextField)
        self.view.addSubview(passwordTextField)
        self.view.addSubview(signInButton)
        
        // 레이아웃 설정
        idTextField.snp.makeConstraints { make in
            make.centerX.equalTo(self.view)
            make.centerY.equalTo(self.view).offset(-30)
            make.width.equalTo(300)
            make.height.equalTo(40)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.centerX.equalTo(self.view)
            make.top.equalTo(idTextField.snp.bottom).offset(20)
            make.width.equalTo(300)
            make.height.equalTo(40)
        }
        
        signInButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-40)
            make.centerX.equalTo(self.view)
            make.width.equalTo(333)
            make.height.equalTo(57)
        }
    }
    
    @objc func signInButtonTapped() {
        guard let email = idTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "이메일과 비밀번호를 입력해주세요.")
            return
        }
        
        let parameters: [String: Any] = ["email": email, "password": password]
        
        // 파라미터 출력 (디버깅용)
        print("Parameters: \(parameters)")
        
        AF.request("http://na2ru2.me:5152/members/login", method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: LoginResponse.self) { response in
                switch response.result {
                case .success(let loginResponse):
                    if let httpResponse = response.response, httpResponse.statusCode == 200 {
                        if let headers = httpResponse.allHeaderFields as? [String: String], let jwtToken = headers["Authorization"] {
                            // JWT 토큰 저장
                            UserDefaults.standard.set(jwtToken, forKey: "jwtToken")
                            
                            DispatchQueue.main.async {
                                let mainTabBarController = MainTabBarController()
                                self.navigationController?.pushViewController(mainTabBarController, animated: true)
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.showAlert(message: "JWT 토큰을 찾을 수 없습니다.")
                            }
                        }
                    }
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                            print("Response JSON: \(loginResponse)")  // 서버로부터 응답 받은 JSON 출력
                            if let validationErrors = loginResponse.validationErrors {
                                let errors = validationErrors.map { $0.reason }.joined(separator: "\n")
                                DispatchQueue.main.async {
                                    self.showAlert(message: errors)
                                }
                            } else if let message = loginResponse.message {
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

