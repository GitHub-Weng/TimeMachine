# TimeMachine
an app to show our appearance change 



## 第一阶段：App产品框架的制定

1 产品功能构想：
运行软件后，在首界面有三个选项可以选择，分别是上传照片，模板选择选择以及观看视频，主界面的三个选项对应三个按钮，单击之后分别跳转不同的Activity。其中的上传照片对应着UpLoadActivity，在该Activity中实现了从本地打开照片以及打开照相机拍照的功能，选定照片之后将照片显示在ImageView中，除此之外，还有一个处理选项，选择处理选项之后可以将选定的照片发到服务器进行处理，服务器对照片进行处理之后将结果返回给手机客户端软件，客户端软件将收到的效果图片存储起来。TemplateActivity对应着的是模板话功能，打算对生成的视频套用模板，使得最终产生的视频可以个性化制定。Vedio_Display则是选择播放视频的Activity,将从服务器得到的照片经过处理之后得到视频，并播放视频。

2 功能模块调整：
初步将产品的App实现之后，得到一个App框架，其中每个选项的功能还需要进一步具体实现，在实现之前要根据项目的实际进度和剩余时间来对App的功能进行规划调整。Vedio_Display功能其实可以不用实现，在UpLoadAcitvity 中显示最后的结果即可，当客户端接受到服务器的最终结果时，客户端应该将最后结果图进行处理，生成视频并保存起来，用户可以选择是否要在当前页面播放生成的视频。这样用户就可以在第一时间内看到最后的结果，而不必重新退回到主界面再进行选择播放相应的视频，因此将Vedio_Display模块删除。至于TemplateActivity，目前不能实现将模板的风格套用到整个视频中，所以这个功能暂时保留，等待后续有时间继续完善。因此项目的核心在于UpLoadActivity功能的设计以及实现。

## 第二阶段：与服务器端进行图片传输功能的实现

服务器端是用JAVA代码实现文件传输的，利用的是Socket编程来进行文件传输，文件的传输暂时是利用校园网网络进行实验。Android端的代码也是用Socket编程实现和服务器端的对接。这一块的功能对应客户端的图片处理功能，当处理功能被选择时，会将选择好的文件传输到服务器端，服务器端保存起来准备下一步的处理流程。基局域网的文件传输效果很快，大约1秒内就可以将一张几M的图片传输完成，为了快速展示，目前使用的还是基于校内网的文件传输机制。

## 第三阶段：调用Matlab函数
 
服务器端使用的是Matlab软件对图片进行处理，处理完成之后将结果保存在服务器上。App端向运行着的服务器软件（JAVA程序）发送请求之后，JAVA程序要再次和服务器端运行着的Matlab程序进行通信，让Matlab处理从客户端传输过来的图片。这里采用的是Matlab下的Socket通信，一旦接收到从JAVA程序发过来的信号，就从本地读取已经保存好的图片，处理完成将生成的一些列图片再写回制定好的文件夹，在由JAVA程序将指定文件夹中的图片发到客户端，从而完成了对原始图片的处理。

## 第四阶段：生成Gif动态图片展示
最初的设想是想生成视频，但是按照已有的技术，最大的可能也是将最后得到的处理图片做成视频帧来播放，实现的效果就跟ppt中的幻灯片播放照片一样，而且生成视频还有一个问题，就是最后产生的文件过大。基于上述问题，我们决定利用Gif图来代替视频，起到同样的展示效果，节省了流量的同时也加快了整个的处理流程。最初的Gif生成的代码是参考自Github上的一个GIFMakerDemo的工程，但是只是一个Demo的原因，实现起来效果很差。虽然能后实现生成Gif图片的功能，但是每次生成所花费的时间成本极高，利用两张片生成一张Gif图要将近10s,对于处理更多张图片的话耗时很高，用户体验差。对此对代码进行了修改，修改之后的代码可以根据待处理图片的质量来进行不同程度的优化，用户也可以选择最后生成Gif图的质量来控制对应的生成时间，将处理速度提升了4-5倍。

## 第五阶段：App程序分享功能的实现
现在越来越多的软件都有分享的功能，在老师的提议下也完成了这部分功能的实现，在得到处理的结果，用户选择了生成的Gif图质量之后，用户可以自行将处理的最后结果发到朋友圈或者其他的软件，实现了分享的功能。

## 第六阶段：App整体界面的完善
整个软件的大致功能都已经实现，目前需要对软件进行进一步的调整优化，使得界面看上去简单美观。这一个部分主要是对原来App中组件的样式进行设定，选择合适的图片作为素材，使得整个产品更加和谐。





