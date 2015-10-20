ssloadURLImage使用文档

概括：为了解决加载网络图片时的繁琐操作，封装了路径操作、加载操作、下载操作、缓存到本地操作，目前只针对UIImageView做的image加载，如果想针对UIButton或者其他加载图像的地方做扩展，可根据代码内部的注释做修改

功能：根据图片URL、本地路径（沙箱目录+具体目录）、保存名等参数，首先会根据路径查找是否有该名的图片文件，如果有则直接加载到载体，如果没有则启动下载操作，下载成功后先保存在本地，然后加载到载体上。

特殊说明：已针对频繁更换图片的条件做了优化，也就是说调用了一次方法之后，如果再次调用方法，参数一样的话，则不执行该下载方法（因为已经在执行了）。如果和上一次调用的参数不同，则取消上一次的下载、加载等操作，从新根据本次提交的参数执行方法。

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

配置参数：
public static var imageURL             : NSString  = ""//图片URL地址
    public static var imageSaveName        : NSString  = "12.png"//下载成功的图片保存名
    public static var sandboxName          : NSInteger = 10//沙箱位置 0:Documents 10:Library-Caches 11:Library-Preferences 2:temp
    public static var savePath             : NSString  = "image/catch"//沙箱中的具体路径，不以"/"开头，不以"/"结尾，如为空，则在该沙箱目录的根目录存储
    public static var beforeLoadImage      : UIImage?   = nil//图片下载之前显示的图片（一般显示加载中之类的图片）
    public static var loadErrorImage       : UIImage?   = nil//图片下载失败显示的图片
    public static var changeImageAnimation : Bool      = true//图片下载成功后，切换图片是否使用动画

特殊说明：
本人第一次写这种类库，多多少少会有一些瑕疵，还是希望能够和各位大牛成为朋友，一起共勉
