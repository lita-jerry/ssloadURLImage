/*
使用范例：
已知imageview为UIImageView类型
swift：
//根据图片URL和保存名称加载图片（前提要在库中结构体内设置好沙箱目录和具体路径）
self.imageview .loadURLImage(imageURL: "https://www.baidu.com/img/bd_logo1.png", imageSaveName: “baidu.png”)
//取消加载
self.imageview.stopDownLoad()

OC:
//根据图片URL和保存名称加载图片（前提要在库中结构体内设置好沙箱目录和具体路径）
[self.imageview loadURLImageWithImageURL:@"http://m.360buyimg.com/mobilecms/jfs/t1615/170/1303619594/8149/1f8336b8/55c2bcdfNf12c72c2.png" imageSaveName:@“baidu.png"];
//取消加载
[self.imageview stopDownLoad];

如果已经开始了一次加载，如需要更换加载的图片，可以再次执行一次，将新的参数更换即可加载最新图片（如果本地已经存在这张图片，则在加载之前使用另外一段代码忽略本地缓存）
//忽略本地缓存
swift:
self.imageview.usedCatch = false
OC:
imageview.useCatch = NO;
*/

import Foundation
import UIKit
public struct menuOptions {
    public static var imageURL             : NSString  = ""//图片URL地址
    public static var imageSaveName        : NSString  = "12.png"//下载成功的图片保存名
    public static var sandboxName          : NSInteger = 10//沙箱位置 0:Documents 10:Library-Caches 11:Library-Preferences 2:temp
    public static var savePath             : NSString  = "image/catch"//沙箱中的具体路径，不以"/"开头，不以"/"结尾，如为空，则在该沙箱目录的根目录存储
    public static var beforeLoadImage      : UIImage?   = nil//图片下载之前显示的图片（一般显示加载中之类的图片）
    public static var loadErrorImage       : UIImage?   = nil//图片下载失败显示的图片
    public static var changeImageAnimation : Bool      = true//图片下载成功后，切换图片是否使用动画
}


//以下设置，请勿修改
private var ssloadURLImage_status               : UnsafePointer<NSInteger> = nil//0无下载任务（或取消） 1正在下载 -1失败
private var ssloadURLImage_imageURL             : UnsafePointer<NSString>  = nil
private var ssloadURLImage_imageSaveName        : UnsafePointer<NSString>  = nil
private var ssloadURLImage_sandboxName          : UnsafePointer<NSInteger> = nil
private var ssloadURLImage_savePath             : UnsafePointer<NSString>  = nil
private var ssloadURLImage_beforeLoadImage      : UnsafePointer<UIImage>   = nil
private var ssloadURLImage_loadErrorImage       : UnsafePointer<UIImage>   = nil
private var ssloadURLImage_changeImageAnimation : UnsafePointer<UIImage>   = nil
private var ssloadURLImage_useCatch             : UnsafePointer<Bool>      = nil
extension UIImageView{
    //动态添加扩展变量
    var status : NSInteger {
        get{
            let result = objc_getAssociatedObject(self, &ssloadURLImage_status) as? NSInteger
            if result == nil {return 0}
            return result!
        }
        set{objc_setAssociatedObject(self, &ssloadURLImage_status, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)}
    }
    var imageURL : NSString {
        get{
            let result = objc_getAssociatedObject(self, &ssloadURLImage_imageURL) as? NSString
            if result == nil {return menuOptions.imageURL}
            return result!
        }
        set{objc_setAssociatedObject(self, &ssloadURLImage_imageURL, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)}
    }
    var imageSaveName : NSString {
        get{
            let result = objc_getAssociatedObject(self, &ssloadURLImage_imageSaveName) as? NSString
            if result == nil {return menuOptions.imageSaveName}
            return result!
        }
        set{objc_setAssociatedObject(self, &ssloadURLImage_imageSaveName, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)}
    }
    var sandboxName : NSInteger {
        get{
            let result = objc_getAssociatedObject(self, &ssloadURLImage_sandboxName) as? NSInteger
            if result == nil {return menuOptions.sandboxName}
            return result!
        }
        set{objc_setAssociatedObject(self, &ssloadURLImage_sandboxName, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)}
    }
    var savePath : NSString {
        get{
            let result = objc_getAssociatedObject(self, &ssloadURLImage_savePath) as? NSString
            if result == nil {return menuOptions.savePath}
            return result!
        }
        set{objc_setAssociatedObject(self, &ssloadURLImage_savePath, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)}
    }
    var beforeLoadImage : UIImage? {
        get{
            let result = objc_getAssociatedObject(self, &ssloadURLImage_beforeLoadImage) as? UIImage
            if result == nil {
                if(menuOptions.beforeLoadImage == nil){
//                    let image : UIImage = UIImage()
                    return nil
                }else{
                    return menuOptions.beforeLoadImage!
                }
            }
            return result!
        }
        set{objc_setAssociatedObject(self, &ssloadURLImage_beforeLoadImage, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)}
    }
    var loadErrorImage : UIImage? {
        get{
            let result = objc_getAssociatedObject(self, &ssloadURLImage_loadErrorImage) as? UIImage
            if result == nil {
                if(menuOptions.loadErrorImage == nil){
//                    let image : UIImage = UIImage()
                    return nil
                }else{
                    return menuOptions.loadErrorImage!
                }
            }
            return result!
        }
        set{objc_setAssociatedObject(self, &ssloadURLImage_loadErrorImage, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)}
    }
    var changeImageAnimation : Bool {
        get{
            let result = objc_getAssociatedObject(self, &ssloadURLImage_changeImageAnimation) as? Bool
            if result == nil {return menuOptions.changeImageAnimation}
            return result!
        }
        set{objc_setAssociatedObject(self, &ssloadURLImage_changeImageAnimation, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)}
    }
    var usedCatch : Bool {
        get{
            let result = objc_getAssociatedObject(self, &ssloadURLImage_useCatch) as? Bool
            if result == nil {return true}//默认使用本地缓存
            return result!
        }
        set{objc_setAssociatedObject(self, &ssloadURLImage_useCatch, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)}
    }
    
    ///指定图片下载地址、图片下载成功后保存的名称
    func loadURLImage(imageURL _imageURL : NSString , imageSaveName _imageSaveName : NSString ){
        //将参数提交到汇聚方法
        self.loadURLImage(imageURL: _imageURL, imageSaveName: _imageSaveName, sandboxName: self.sandboxName, savePath: self.savePath, beforeLoadImage: self.beforeLoadImage!, loadErrorImage: self.loadErrorImage, changeImageAnimation: self.changeImageAnimation)
    }
    ///指定图片下载地址、图片下载成功后保存的名称、保存在哪个沙箱目录下、沙箱目录下的具体路径
    func loadURLImage( imageURL _imageURL : NSString , imageSaveName _imageSaveName : NSString , sandboxName _sandboxName : NSInteger , savePath _savePath : NSString ){
        //将参数提交到汇聚方法
        self.loadURLImage(imageURL: _imageURL, imageSaveName: _imageSaveName, sandboxName: _sandboxName, savePath: _savePath, beforeLoadImage: self.beforeLoadImage!, loadErrorImage: self.loadErrorImage, changeImageAnimation: self.changeImageAnimation)
    }
    ///指定图片下载地址、图片下载成功后保存的名称、保存在哪个沙箱目录下、沙箱目录下的具体路径、图片下载前的默认显示图片、图片下载失败显示的图片
    func loadURLImage( imageURL _imageURL : NSString , imageSaveName _imageSaveName : NSString , sandboxName _sandboxName : NSInteger , savePath _savePath : NSString , beforeLoadImage _beforeLoadImage : UIImage? , loadErrorImage _loadErrorImage : UIImage?){
        //将参数提交到汇聚方法
        self.loadURLImage(imageURL: _imageURL, imageSaveName: _imageSaveName, sandboxName: _sandboxName, savePath: _savePath, beforeLoadImage: _beforeLoadImage, loadErrorImage: _loadErrorImage, changeImageAnimation: self.changeImageAnimation)
    }
    ///指定图片下载地址、图片下载成功后保存的名称、图片下载前的默认显示图片、图片下载失败显示的图片
    func loadURLImage( imageURL _imageURL : NSString , imageSaveName _imageSaveName : NSString , beforeLoadImage _beforeLoadImage : UIImage? , loadErrorImage _loadErrorImage : UIImage? ){
        //将参数提交到汇聚方法
        self.loadURLImage(imageURL: _imageURL, imageSaveName: _imageSaveName, sandboxName: self.sandboxName, savePath: self.savePath, beforeLoadImage: _beforeLoadImage, loadErrorImage: _loadErrorImage, changeImageAnimation: self.changeImageAnimation)
    }
    //将所有带参数的方法汇聚到一个方法中执行
    func loadURLImage(imageURL _imageURL : NSString , imageSaveName _imageSaveName : NSString , sandboxName _sandboxName : NSInteger , savePath _savePath : NSString , beforeLoadImage _beforeLoadImage : UIImage? , loadErrorImage _loadErrorImage : UIImage? , changeImageAnimation _changeImageAnimation : Bool){
        let lock : NSLock = NSLock()
        lock.lock()
        //首先查询当前状态
        //如果当前是空闲状态
        if(self.status == 0 || self.status == -1){
            //先赋值
            self.imageURL             = _imageURL
            self.imageSaveName        = _imageSaveName
            self.sandboxName          = _sandboxName
            self.savePath             = _savePath
            self.beforeLoadImage      = _beforeLoadImage
            self.loadErrorImage       = _loadErrorImage
            self.changeImageAnimation = _changeImageAnimation
            
            //如果当前图片为空，在执行方法之前先加载默认图片
            if(self.image == nil){
                self.image = self.beforeLoadImage
            }
            //获取文件夹路径
            let path = self.getPath()
            if(path == nil){return}
            NSLog((path) as! String)
            //查找是否有同名image
            let file : NSFileManager = NSFileManager()
            do{//说实话我主要用的是OC，swift的 try catch用不好，见笑了
                try file.createDirectoryAtPath(path as! String, withIntermediateDirectories: true, attributes: nil)
            }catch{return}
            //获取文件存储路径（路径+文件名）
            let imagePath = path!.stringByAppendingString(self.imageSaveName as String)
            NSLog(imagePath)
            //检查用户是否使用本地缓存
            if(self.usedCatch){
                //如果使用本地缓存
                //检查本地是否有该图片，如果有，则加载到imageview ————end
                if(file.fileExistsAtPath(imagePath)){
                    //将图片显示在imageview上面，方法结束
                    self.setImageToView(imagePath)
                    return
                }
            }
            
            //如果当前目录内没有，启动下载
            self.startDownLoad()
            lock.unlock()
        }
            //如果状态是正在下载中
        else if(self.status == 1){
            //检查图片下载地址、图片名、沙箱目录、保存路径是否与之前提交的一样，如果不一样，则改变当前状态为0，重新执行该方法
            if( self.imageURL == _imageURL && self.imageSaveName == _imageSaveName && self.sandboxName == _sandboxName && self.savePath == _savePath && self.changeImageAnimation ){
                NSLog("正在下载中，不要重复提交")
                lock.unlock()
                return
            }
            self.status = 0
            self.loadURLImage(imageURL: _imageURL, imageSaveName: _imageSaveName, sandboxName: _sandboxName, savePath: _savePath, beforeLoadImage: _beforeLoadImage, loadErrorImage: _loadErrorImage, changeImageAnimation: _changeImageAnimation)
        }else{
            lock.unlock()
            return
        }
    }
    //获取沙箱地址
    func getSandboxPath()->NSString?{
        //沙箱位置 0:Documents 10:Library-Caches 11:Library-Preferences 2:temp
        var path : NSString!
        switch(self.sandboxName){
        case 0:
            let documentDirectory : NSArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            path = documentDirectory.lastObject as! NSString
            return path
            
        case 10:
            let Library_Caches : NSArray = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
            path = Library_Caches.lastObject as! NSString
            return path
            
        case 11:
            let Library_Preferences : NSArray = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true)
            path = Library_Preferences.lastObject as! NSString
            return path
            
        case 2:
            let tmpDirectory = NSTemporaryDirectory()
            return tmpDirectory
            
        default:
            return nil
        }
    }
    //获取文件夹路径
    func getPath()->NSString?{
        //获取沙箱地址
        let SandboxPath : NSString? = self.getSandboxPath()
        if(SandboxPath == nil){return nil}
        
        var path = self.savePath
        if(path.length != 0){
            path = (SandboxPath?.stringByAppendingString("/"))!.stringByAppendingString(path as String).stringByAppendingString("/")
        }else{
            path = (SandboxPath?.stringByAppendingString("/"))!
        }
        return path
    }
    //将图片加载到imageview上
    func setImageToView( path : NSString ){
        //是否需要动画效果展示
        if(self.changeImageAnimation){
            UIView.animateWithDuration(1, animations: { () -> Void in
                self.alpha = 0
                self.image = UIImage(contentsOfFile: path as String)
                self.alpha = 1
            })
        }else{
            self.image = UIImage(contentsOfFile: path as String)
        }
    }
    //启动下载
    func startDownLoad(){
        //标记正在下载
        self.status = 1
        //保存临时变量，用于图片下载完成后的校验
        let dowdload_imageURL             = self.imageURL
        let download_imageSaveName        = self.imageSaveName
        let download_sandboxName          = self.sandboxName
        let download_savePath             = self.savePath
        //启动异步下载
        let request : NSURLRequest = NSURLRequest(URL: NSURL(string:dowdload_imageURL as String)!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (resp : NSURLResponse?, data : NSData?, error : NSError?) -> Void in
            if(data != nil){
                //校验是否最新请求，以及用户是否取消请求，求出的值非运算，满足的话直接退出
                if(!( dowdload_imageURL == self.imageURL && download_imageSaveName == self.imageSaveName && download_sandboxName == self.sandboxName && download_savePath == self.savePath && self.status == 1 )){
                    NSLog("本次操作已被覆盖或者用户取消");
                    return
                }
                if( dowdload_imageURL == self.imageURL ){
                    //将图片保存
                    let func_imagePath : NSString = (self.getPath()?.stringByAppendingString(self.imageSaveName as String))!
                    let file : NSFileManager = NSFileManager()
                    file.createFileAtPath(func_imagePath as String, contents: data, attributes: nil)
                    self.setImageToView(func_imagePath)
                    self.status = 0
                }
            }else{
                NSLog("请求失败");
                self.status = 0
            }
        }
    }
    //停止下载
    func stopDownLoad(){
        //标记为已取消
        self.status = 0
    }
}


