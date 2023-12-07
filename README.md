# MapDemo

## 1.主要功能

### 1.1 显示当前定位
### 1.2 支持缩放、滑动
### 1.3 选取地图点做目的地
### 1.4 开始导航
如果没有选取目的地，会有提示“还没选择目的地”

导航开始的时候，会有一条规划好的路线，缩放比例18，默认进入缩放是16
### 1.5 状态提示
开始导航时，会显示3个状态：
耗时、距离、gps信号

### 1.6 结束导航

按结束按钮，结束导航，会提示耗时、距离、gps信号

## 2.实现过程

### 2.1 集成GoogleMaps

[Google map sdk for iOS](https://developers.google.com/maps/documentation/ios-sdk/controls?hl=zh-cn)用于展示当前定位，最开始用的邮件里面APIKey，后面突然不能用了，就自己申请了一个APIKey。

### 2.2 导航

我搜索`Google map navigation for iOS`确实可以找到一个导航的SDK，[Google Navigation SDK for iOS](https://developers.google.com/maps/documentation/navigation/ios-sdk/route?hl=zh-cn)，集成了之后发现怎么都提示cancel，一开始不知道是什么原因，看文档才发现，这个SDK需要申请审核后才能使用，就暂时放弃了。

后面又找到了一个路线规划的API，[Directions API](https://developers.google.com/maps/documentation/directions/get-directions?hl=zh-cn#DirectionsResponses)可以查询到路径，绘制到地图上就可以了。

实时导航，就只能在`didUpdateLocations`代理方法里面使用`self.mapView.animate(to: camera)`

### 2.3 状态展示

耗时：目前就用定时器计时
距离：叠加`didUpdateLocations`代理里距离值
GPS信号：
目前Google map SDK没有提供现成的接口获取，只能通过`CLLocation`的`horizontalAccuracy`简单估计一下信号强弱
horizontalAccuracy < 0, 没有信号
horizontalAccuracy > 143, 信号弱
horizontalAccuracy [48, 143), 信号一般
horizontalAccuracy [0, 48), 信号强


