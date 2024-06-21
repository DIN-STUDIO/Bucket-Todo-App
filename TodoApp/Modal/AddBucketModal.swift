import UIKit
import SnapKit
import Alamofire

class AddBucketModal: UIViewController {
    
    let textView = UITextView()
    let submitButton = UIButton()
    let instructionLabel = UILabel()
    let backButton = UIButton() // 커스텀 back 버튼 추가
    
    var onDismiss: (() -> Void)? // 모달 창이 닫힐 때 호출할 클로저
    var onSubmit: ((String) -> Void)? // 텍스트 제출 시 호출할 클로저
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.view.layer.cornerRadius = 20
        self.view.clipsToBounds = true
        
        // 기본 제공되는 back 버튼 제거
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.hidesBackButton = true
        
        // 커스텀 back 버튼 설정
        backButton.setTitle("뒤로가기", for: .normal)
        backButton.setTitleColor(.blue, for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        // 안내 라벨 설정
        instructionLabel.text = "내용을 작성해주세요"
        instructionLabel.font = UIFont.systemFont(ofSize: 16)
        instructionLabel.textColor = .black
        
        // 텍스트뷰 설정
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor.gray.cgColor
        textView.layer.cornerRadius = 10
        textView.font = UIFont.systemFont(ofSize: 16)
        
        // 등록하기 버튼 설정
        submitButton.setTitle("등록하기", for: .normal)
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.backgroundColor = UIColor(red: 255/255.0, green: 157/255.0, blue: 0/255.0, alpha: 1.0)
        submitButton.layer.cornerRadius = 20
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        
        // 뷰에 추가
        self.view.addSubview(backButton)
        self.view.addSubview(instructionLabel)
        self.view.addSubview(textView)
        self.view.addSubview(submitButton)
        
        // 레이아웃 설정
        backButton.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(10)
            make.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading).offset(10)
        }
        
        instructionLabel.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(20)
            make.centerX.equalTo(self.view)
        }
        
        textView.snp.makeConstraints { make in
            make.top.equalTo(instructionLabel.snp.bottom).offset(20)
            make.leading.equalTo(self.view).offset(20)
            make.trailing.equalTo(self.view).offset(-20)
            make.height.equalTo(200)
        }
        
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(textView.snp.bottom).offset(20)
            make.centerX.equalTo(self.view)
            make.width.equalTo(150)
            make.height.equalTo(50)
        }
    }
    
    @objc func backButtonTapped() {
        self.dismiss(animated: true) {
            self.onDismiss?() // 모달 창이 닫힐 때 클로저 호출
        }
    }
    
    @objc func submitButtonTapped() {
        guard let content = textView.text, !content.isEmpty else {
            print("내용을 입력해주세요.")
            return
        }
        
        // 현재 날짜를 deadLine으로 설정
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentDate = dateFormatter.string(from: Date())
        
        let parameters: [String: Any] = ["content": content, "deadLine": currentDate]
        guard let jwtToken = UserDefaults.standard.string(forKey: "jwtToken") else {
            print("JWT 토큰이 없습니다.")
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(jwtToken)",
            "Content-Type": "application/json"
        ]
        
        AF.request("http://na2ru2.me:5152/buckets", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: BucketResponse.self) { response in
                switch response.result {
                case .success(let bucketResponse):
                    print("버킷이 성공적으로 등록되었습니다.")
                    print("등록된 버킷 ID: \(bucketResponse.response?.bucketId ?? 0)")
                    DispatchQueue.main.async {
                        self.onSubmit?(content)
                        self.dismiss(animated: true, completion: self.onDismiss)
                    }
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                            print("서버 오류 메시지: \(errorResponse.message)")
                            for validationError in errorResponse.validationErrors {
                                print("필드: \(validationError.field), 이유: \(validationError.reason)")
                            }
                        } catch {
                            print("오류 응답을 디코딩하는 데 실패했습니다: \(error)")
                        }
                    } else {
                        print("Error: \(error)")
                    }
                }
            }
    }
}
