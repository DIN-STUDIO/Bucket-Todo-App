import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myBucketVC = MyBucketVC()
        let ourBucketVC = OurBucketVC()
        
        myBucketVC.tabBarItem = UITabBarItem(title: "My 버킷 투두", image: UIImage(), tag: 0)
        ourBucketVC.tabBarItem = UITabBarItem(title: "Our 버킷 투두", image: UIImage(), tag: 1)
        
        let tabBarList = [myBucketVC, ourBucketVC]
        
        viewControllers = tabBarList.map { UINavigationController(rootViewController: $0) }
    }
}

