# cocos-desktop-webview
cocos UIWebView在windows和mac平台上的适配

## 环境配置
1. `source`文件夹下为新增文件，按路径拷贝到响应位置，并加到对应工程项目中。
2. mac项目需要在主工程和cocos工程中添加`WebKit.framework`依赖
3. 在相关的平台判断中，加入新增的两个平台，包括以下几个文件

 * `UIWebView.h`

 ```
 	//old
 	#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_TIZEN) && !defined(CC_PLATFORM_OS_TVOS)
 
 	//new
 	#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 || CC_TARGET_PLATFORM == CC_PLATFORM_MAC || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_TIZEN) && !defined(CC_PLATFORM_OS_TVOS)
```

 * `UIWebView.cpp`

 ```
 	//old
	#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_TIZEN)
	#include "ui/UIWebViewImpl-android.h"
	#include "ui/UIWebView-inl.h"
	#endif
	
 	//new
	#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_TIZEN)
	#include "ui/UIWebViewImpl-android.h"
	#include "ui/UIWebView-inl.h"
	
	#elif (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	#include "ui/UIWebViewImpl-win32.h"
	#include "ui/UIWebView-inl.h"
	#endif
 ```
 
  * `UIWebView.mm`
  
  ```
  	//old
   #if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_IOS) && !defined(CC_PLATFORM_OS_TVOS)
   
	//new
	#if (CC_TARGET_PLATFORM == CC_PLATFORM_MAC || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_IOS) && !defined(CC_PLATFORM_OS_TVOS)

 ```
 * `CocosGUI.h`
 
 ```
 	//old
 	#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_TIZEN)
	#include "ui/UIWebView.h"
	#endif

 	//new
	#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 || CC_TARGET_PLATFORM == CC_PLATFORM_MAC || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_TIZEN)
	#include "ui/UIWebView.h"
	#endif
 ```
 
3. 脚本导出

 	以lua为例，也是在相关文件判断中添加平台，包括以下文件
 	* `scripting/lua-bindings/auto/lua_cocos2dx_experimental_webview_auto.cpp`
 	* `scripting/lua-bindings/auto/lua_cocos2dx_experimental_webview_auto.hpp`
 	* `scripting/lua-bindings/manual/ui/lua_cocos2dx_experimental_webview_manual.cpp`
 	* `scripting/lua-bindings/manual/ui/lua_cocos2dx_experimental_webview_manual.hpp`
 	* `scripting/lua-bindings/manual/ui/lua_cocos2dx_ui_manual.cpp`
 	
 		```
 		//old
	 	#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_IOS) && !defined(CC_TARGET_OS_TVOS)
		#include "scripting/lua-bindings/auto/lua_cocos2dx_experimental_video_auto.hpp"
		#include "scripting/lua-bindings/manual/ui/lua_cocos2dx_experimental_video_manual.hpp"
		#include "scripting/lua-bindings/auto/lua_cocos2dx_experimental_webview_auto.hpp"
		#include "scripting/lua-bindings/manual/ui/lua_cocos2dx_experimental_webview_manual.hpp"
		#endif
		
		//new
	 	#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_IOS) && !defined(CC_TARGET_OS_TVOS)
		#include "scripting/lua-bindings/auto/lua_cocos2dx_experimental_video_auto.hpp"
		#include "scripting/lua-bindings/manual/ui/lua_cocos2dx_experimental_video_manual.hpp"
		#endif
		
		#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 || CC_TARGET_PLATFORM == CC_PLATFORM_MAC) && !defined(CC_TARGET_OS_TVOS)
		#include "scripting/lua-bindings/auto/lua_cocos2dx_experimental_webview_auto.hpp"
		#include "scripting/lua-bindings/manual/ui/lua_cocos2dx_experimental_webview_manual.hpp"
		#endif
 		```
 		```
 		//old
 		#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_IOS) && !defined(CC_TARGET_OS_TVOS)
        	register_all_cocos2dx_experimental_video(L);
        	register_all_cocos2dx_experimental_video_manual(L);
        	register_all_cocos2dx_experimental_webview(L);
        	register_all_cocos2dx_experimental_webview_manual(L);
		#endif
		
		//new
		#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_IOS) && !defined(CC_TARGET_OS_TVOS)
        	register_all_cocos2dx_experimental_video(L);
        	register_all_cocos2dx_experimental_video_manual(L);
		#endif
		
		#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 || CC_TARGET_PLATFORM == CC_PLATFORM_MAC) && !defined(CC_TARGET_OS_TVOS)
       	register_all_cocos2dx_experimental_webview(L);
       	register_all_cocos2dx_experimental_webview_manual(L);
		#endif

 		```

## 常见问题

1. Mac打不开`https`网址：`Info.plist`中添加`NSAppTransportSecurity`配置，参考[苹果文档翻译 iOS10 NSAppTransportSecurity](https://www.jianshu.com/p/1ec3fa1ec00f)
2. TODO
  * `setJavascriptInterfaceScheme`接口支持

## 效果图
![](https://github.com/lyzz0612/cocos_desktop_webview/raw/master/preview/mac.png)

![](https://github.com/lyzz0612/cocos_desktop_webview/raw/master/preview/windows.png)