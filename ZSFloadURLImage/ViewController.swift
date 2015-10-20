//
//  ViewController.swift
//  ZSFloadURLImage
//
//  Created by 赵胜峰 on 15/10/17.
//  Copyright © 2015年 zhaoshengfeng. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var i: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
//        var test : UIImageView = UIImageView()
//        test.image = UIImage(named: "")
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func testttt(sender: AnyObject) {
        self.i.usedCatch = false
//        self.i.loadURLImage(imageURL: "http://m.360buyimg.com/mobilecms/jfs/t1615/170/1303619594/8149/1f8336b8/55c2bcdfNf12c72c2.png", imageSaveName: "12.png")
        self.i.loadURLImage(imageURL: "http://m.360buyimg.com/mobilecms/jfs/t1615/170/1303619594/8149/1f8336b8/55c2bcdfNf12c72c2.png", imageSaveName: "12.png", beforeLoadImage: UIImage(named: "u14.png")!, loadErrorImage: UIImage(named: "u14.png")!)
        //执行停止后，就不会加载到载体了
//        self.i.stopDownLoad()
        //如果注释下面的这一行，加载的图片就是京东的二维码，如果不注释下面这行代码已经替换掉了上面的代码，加载的是百度LOGO，上行代码将无效
//        self.i.loadURLImage(imageURL: "https://www.baidu.com/img/bd_logo1.png", imageSaveName: "12.png")
        
    }

}

