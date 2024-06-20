import UIKit
import SnapKit

class SignUpSecondVC: UIViewController {
    var email: String?
    var password: String?
    var nickName: String?
    
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
        signUpGuideMsg.text = "수고하셨습니다!"
        signUpGuideMsg.textAlignment = .center
        signUpGuideMsg.font = UIFont.boldSystemFont(ofSize: 22)
        signUpGuideMsg.textColor = .black
        
        // 회원가입 버튼 생성 및 설정
        let signUpButton = UIButton(type: .system)
        signUpButton.setTitle("버킷 투두 바로가기", for: .normal)
        signUpButton.setTitleColor(buttonTitleColor, for: .normal)
        signUpButton.backgroundColor = buttonBackgroundColor
        signUpButton.layer.cornerRadius = 15
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        
        // 뷰에 추가
        self.view.addSubview(signUpGuideMsg)
        self.view.addSubview(signUpButton)
        
        // 레이아웃 설정
        signUpGuideMsg.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(40)
            $0.centerX.equalTo(self.view)
        }
        
        signUpButton.snp.makeConstraints {
            $0.bottom.equalTo(view.snp.bottom).offset(-40)
            $0.centerX.equalTo(self.view)
            $0.width.equalTo(333)
            $0.height.equalTo(57)
        }
    }
    
    @objc func signUpButtonTapped() {
        let moveVC = SignInVC()
        self.navigationController?.pushViewController(moveVC, animated: true)
    }
}


