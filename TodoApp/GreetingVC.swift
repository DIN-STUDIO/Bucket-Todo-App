import UIKit
import SnapKit

class GreetingVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let buttonTitleColor = UIColor(red: 255/255.0, green: 157/255.0, blue: 0/255.0, alpha: 1.0)
        let buttonBackgroundColor = UIColor(red: 255/255.0, green: 248/255.0, blue: 238/255.0, alpha: 1.0)
        
        // signUpBtn 생성 및 설정
        let signUpBtn = UIButton(type: .system)
        signUpBtn.setTitle("신규 회원가입", for: .normal)
        signUpBtn.setTitleColor(buttonTitleColor, for: .normal)
        signUpBtn.backgroundColor = buttonBackgroundColor
        signUpBtn.layer.cornerRadius = 15
        signUpBtn.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        
        // signInBtn 생성 및 설정
        let signInBtn = UIButton(type: .system)
        signInBtn.setTitle("기존 유저 로그인", for: .normal)
        signInBtn.setTitleColor(buttonTitleColor, for: .normal)
        signInBtn.backgroundColor = buttonBackgroundColor
        signInBtn.layer.cornerRadius = 15
        signInBtn.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
        
        // 배경색 설정
        self.view.backgroundColor = .white
        
        // 버튼을 뷰에 추가
        self.view.addSubview(signUpBtn)
        self.view.addSubview(signInBtn)
        
        // SnapKit을 사용하여 signUpBtn 레이아웃 설정
        signUpBtn.snp.makeConstraints {
            $0.centerX.equalTo(self.view)
            $0.centerY.equalTo(self.view.snp.top).offset(706)
            $0.width.equalTo(333)
            $0.height.equalTo(57)
        }
        
        // SnapKit을 사용하여 signInBtn 레이아웃 설정
        signInBtn.snp.makeConstraints {
            $0.centerX.equalTo(self.view)
            $0.top.equalTo(signUpBtn.snp.bottom).offset(14)
            $0.width.equalTo(333)
            $0.height.equalTo(57)
        }
    }
    
    @objc func signUpButtonTapped() {
        let signUpVC = SignUpFirstVC()
        self.navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    @objc func signInButtonTapped() {
        let signInVC = SignInVC()
        self.navigationController?.pushViewController(signInVC, animated: true)
    }
}

