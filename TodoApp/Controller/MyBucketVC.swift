import UIKit
import Alamofire
import SnapKit

class MyBucketVC: UIViewController {
    
    let nicknameLabel = UILabel()
    let addBucketTodoBtn = UIButton()
    var tableView = UITableView()
    var bucketList = [Bucket]() // 버킷 리스트 데이터를 저장할 배열
    var blurEffectView: UIVisualEffectView? // 블러 효과 뷰를 추적하기 위한 프로퍼티
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 배경 색 : FFF8EE 255,248,238
        // 폰트 컬러 : 흰색
        
        self.view.backgroundColor = .white
        
        // 상단 뷰 설정
        let topView = UIView()
        topView.backgroundColor = UIColor(red: 255/255.0, green: 248/255.0, blue: 238/255.0, alpha: 1.0)
        topView.layer.cornerRadius = 50
        topView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner] // 아래쪽 모서리만 라운딩
        
        self.view.addSubview(topView)
        
        topView.snp.makeConstraints { make in
            make.top.equalTo(self.view)
            make.leading.trailing.equalTo(self.view)
            make.height.equalTo(200)
        }
        
        // 닉네임 레이블 설정
        nicknameLabel.textAlignment = .center
        nicknameLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        nicknameLabel.textColor = .black
        
        topView.addSubview(nicknameLabel)
        
        nicknameLabel.snp.makeConstraints {
            $0.centerX.equalTo(topView)
            $0.top.equalTo(topView).offset(120) // 위로 20 이동
        }
        
        // 버킷 투두 추가하기 버튼
        addBucketTodoBtn.setTitle("버킷 투두 추가하기", for: .normal)
        addBucketTodoBtn.setTitleColor(.white, for: .normal)
        addBucketTodoBtn.backgroundColor = UIColor(red: 255/255.0, green: 157/255.0, blue: 0/255.0, alpha: 1.0)
        addBucketTodoBtn.layer.cornerRadius = 10
        addBucketTodoBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold) // 폰트 크기 줄이기
        addBucketTodoBtn.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        // 테이블뷰 설정
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(BucketCell.self, forCellReuseIdentifier: "BucketCell")
        
        // 버튼을 뷰에 추가
        self.view.addSubview(addBucketTodoBtn)
        // 테이블뷰를 뷰에 추가
        self.view.addSubview(tableView)
        
        // 레이아웃 설정
        addBucketTodoBtn.snp.makeConstraints {
            $0.trailing.equalTo(self.view.snp.trailing).offset(-20)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            $0.width.equalTo(184)
            $0.height.equalTo(20) // 높이 줄이기
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(topView.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(self.view).inset(10) // padding 추가
            $0.bottom.equalTo(addBucketTodoBtn.snp.top).offset(-20)
        }
        
        // 사용자 정보 불러오기
        fetchUserInfo()
        // 버킷 리스트 불러오기
        fetchBucketList()
    }
    
    @objc func buttonTapped() {
        let addVC = AddBucketModal()
        addVC.modalPresentationStyle = .overCurrentContext
        addVC.view.backgroundColor = UIColor(white: 1.0, alpha: 0.5) // 흰색에 투명도 적용
        addVC.modalTransitionStyle = .crossDissolve
        addVC.onDismiss = { [weak self] in
            // 블러 효과 제거
            self?.blurEffectView?.removeFromSuperview()
        }
        addVC.onSubmit = { [weak self] text in
            // 텍스트를 받아와서 배열에 추가하고 테이블뷰 갱신
            self?.fetchBucketList()
        }
        self.present(addVC, animated: true) {
            // 블러 처리
            let blurEffect = UIBlurEffect(style: .light)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.view.addSubview(blurEffectView)
            self.view.bringSubviewToFront(addVC.view)
            self.blurEffectView = blurEffectView // 블러 효과 뷰를 저장
            
            // 제약 조건 설정은 뷰가 추가된 후에 해야 합니다.
            addVC.view.snp.makeConstraints { make in
                make.center.equalTo(self.view)
                make.width.equalTo(self.view).multipliedBy(0.8)
                make.height.equalTo(self.view).multipliedBy(0.6)
            }
        }
    }
    
    func fetchUserInfo() {
        guard let jwtToken = UserDefaults.standard.string(forKey: "jwtToken") else {
            print("JWT 토큰이 없습니다.")
            self.nicknameLabel.text = "My 버킷 투두"
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
                            self.nicknameLabel.text = "My 버킷 투두"
                        }
                        return
                    }
                    
                    let memberId = userInfo.memberId
                    let email = userInfo.email
                    let nickname = userInfo.nickname
                    
                    // 사용자 정보 출력
                    print("Member ID: \(memberId)")
                    print("Email: \(email)")
                    print("Nickname: \(nickname)")
                    
                    DispatchQueue.main.async {
                        self.nicknameLabel.text = "\(nickname)님의 버킷 투두리스트"
                    }
                    
                case .failure(let error):
                    print("[MyBucketVC 발생] Error fetching user info: \(error)")
                    DispatchQueue.main.async {
                        self.nicknameLabel.text = "My 버킷 투두"
                    }
                }
            }
    }
    
    func fetchBucketList() {
        guard let jwtToken = UserDefaults.standard.string(forKey: "jwtToken") else {
            print("[MyBucketVC 발생] JWT 토큰이 없습니다.")
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(jwtToken)"
        ]
        
        AF.request("http://na2ru2.me:5152/buckets", method: .get, headers: headers)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: BucketListResponse.self) { response in
                switch response.result {
                case .success(let bucketListResponse):
                    guard let buckets = bucketListResponse.response else {
                        return
                    }
                    
                    self.bucketList = buckets
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                    // 버킷 리스트 출력
                    for bucket in buckets {
                        print("[MyBucketVC 발생] Bucket ID: \(bucket.bucketId), Member ID: \(bucket.memberId)")
                    }
                    
                case .failure(let error):
                    print("[MyBucketVC 발생] Error fetching bucket list: \(error)")
                }
            }
    }
}

// 테이블뷰 데이터소스 및 델리게이트 구현
extension MyBucketVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bucketList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BucketCell", for: indexPath) as! BucketCell
        let bucket = bucketList[indexPath.row]
        cell.configure(bucket: bucket)
        cell.detailButton.addTarget(self, action: #selector(detailButtonTapped(_:)), for: .touchUpInside)
        cell.detailButton.tag = indexPath.row // 버튼에 태그로 인덱스 설정
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100 // 셀의 높이를 증가시켜 여백을 포함
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // 셀의 contentView에 하단 여백 추가
        let bottomSpace: CGFloat = 20
        let maskLayer = CALayer()
        maskLayer.frame = CGRect(x: 0, y: cell.contentView.frame.height - bottomSpace, width: cell.contentView.frame.width, height: bottomSpace)
        maskLayer.backgroundColor = UIColor.white.cgColor
        cell.contentView.layer.addSublayer(maskLayer)
    }
    
    @objc func detailButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        let bucket = bucketList[index]
        let todoVC = TodoVC()
        todoVC.bucketContent = bucket.content
        todoVC.bucketId = bucket.bucketId // bucketId를 전달
        self.navigationController?.pushViewController(todoVC, animated: true)
    }
}

class BucketCell: UITableViewCell {
    
    let heartButton = UIButton()
    let titleLabel = UILabel()
    let detailButton = UIButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        
        // 하트 버튼 설정
        heartButton.setImage(UIImage(named: "heart"), for: .normal)
        heartButton.tintColor = UIColor(red: 255/255.0, green: 157/255.0, blue: 0/255.0, alpha: 1.0)
        heartButton.contentMode = .scaleAspectFit // 이미지가 버튼에 맞게 조정되도록 설정
        
        // 타이틀 라벨 설정
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .black
        
        // 상세 투두리스트 보기 버튼 설정
        detailButton.setTitle("상세 투두리스트 보기", for: .normal)
        detailButton.setTitleColor(.white, for: .normal)
        detailButton.backgroundColor = UIColor(red: 255/255.0, green: 157/255.0, blue: 0/255.0, alpha: 1.0)
        detailButton.layer.cornerRadius = 10
        detailButton.titleLabel?.font = UIFont.systemFont(ofSize: 14) // 버튼 글자 폰트 줄이기
        
        contentView.backgroundColor = UIColor(red: 246/255.0, green: 246/255.0, blue: 246/255.0, alpha: 1.0) // 셀 배경 색 설정
        
        // 뷰에 추가
        contentView.addSubview(heartButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(detailButton)
        
        // 레이아웃 설정
        heartButton.snp.makeConstraints {
            $0.leading.equalTo(contentView).offset(10)
            $0.centerY.equalTo(contentView) // 버튼이 세로로 중앙에 위치하도록 설정
            $0.width.height.equalTo(30)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(heartButton.snp.trailing).offset(10)
            $0.top.equalTo(contentView).offset(10)
        }
        
        detailButton.snp.makeConstraints {
            $0.leading.equalTo(contentView).offset(15)
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.trailing.equalTo(contentView.snp.trailing).offset(-15)
            $0.height.equalTo(20) // 버튼 높이 줄이기
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("[MyBucketVC 발생] init(coder:) has not been implemented")
    }
    
    func configure(bucket: Bucket) {
        titleLabel.text = bucket.content
    }
}
