//
//  UIWebViewImpl-mac.m
//  cocos2d_libs
//
//  Created by lingyun on 2020/2/11.
//
//

#include "platform/CCPlatformConfig.h"

// Webview not available on tvOS
#if (CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
#import <WebKit/WebKit.h>
#include "ui/UIWebViewImpl-ios.h"

#include "renderer/CCRenderer.h"
#include "base/CCDirector.h"
#include "platform/CCGLView.h"
#include "platform/mac/CCApplication-mac.h"
#include "platform/CCFileUtils.h"
#include "ui/UIWebView.h"


@interface UIWebViewWrapper : NSObject
+ (instancetype)webViewWrapper;

@property (nonatomic) std::function<bool(std::string url)> shouldStartLoading;
@property (nonatomic) std::function<void(std::string url)> didFinishLoading;
@property (nonatomic) std::function<void(std::string url)> didFailLoading;
@property (nonatomic) std::function<void(std::string url)> onJsCallback;

@property(nonatomic, readonly, getter=canGoBack) BOOL canGoBack;
@property(nonatomic, readonly, getter=canGoForward) BOOL canGoForward;

- (void)setVisible:(bool)visible;

- (void)setBounces:(bool)bounces;

- (void)setFrameWithX:(float)x y:(float)y width:(float)width height:(float)height;

- (void)setJavascriptInterfaceScheme:(const std::string &)scheme;

- (void)loadData:(const std::string &)data MIMEType:(const std::string &)MIMEType textEncodingName:(const std::string &)encodingName baseURL:(const std::string &)baseURL;

- (void)loadHTMLString:(const std::string &)string baseURL:(const std::string &)baseURL;

- (void)loadUrl:(const std::string &)urlString cleanCachedData:(BOOL) needCleanCachedData;

- (void)loadFile:(const std::string &)filePath;

- (void)stopLoading;

- (void)reload;

- (void)evaluateJS:(const std::string &)js;

- (void)goBack;

- (void)goForward;

- (void)setScalesPageToFit:(const bool)scalesPageToFit;
@end
@interface UIWebViewWrapper () <WKNavigationDelegate>
@property(nonatomic) WKWebView* wkWebView;
@end

@implementation UIWebViewWrapper
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSString* urlStr = navigationAction.request.URL.absoluteString;
    
    WKNavigationActionPolicy policy = WKNavigationActionPolicyAllow;
    if (self.shouldStartLoading) {
        bool shouldLoad = self.shouldStartLoading([urlStr UTF8String]);
        if (!shouldLoad) {
            policy = WKNavigationActionPolicyCancel;
        }
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}


- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    NSString* urlStr = webView.URL.absoluteString;
    if (self.didFinishLoading) {
        self.didFinishLoading([urlStr UTF8String]);
    }
}
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSString* urlStr = webView.URL.absoluteString;
    if (self.didFailLoading) {
        self.didFailLoading([urlStr UTF8String]);
    }}


+ (instancetype)webViewWrapper {
    return [[[self alloc] init] autorelease];
}
- (instancetype)init {
    self = [super init];
    if (self) {
        self.wkWebView = nil;
        self.shouldStartLoading = nullptr;
        self.didFinishLoading = nullptr;
        self.didFailLoading = nullptr;
    }
    
    return self;
}

- (void)setupWebView {
    if (!self.wkWebView) {
        self.wkWebView = [[[WKWebView alloc] init] autorelease];
        self.wkWebView.navigationDelegate = self;
    }
    if (!self.wkWebView.superview) {
        auto view = cocos2d::Director::getInstance()->getOpenGLView();
        NSWindow *window = view->getCocoaWindow();
        
        [window.contentView addSubview:self.wkWebView];
    }
}

- (void)dealloc {
    self.wkWebView.navigationDelegate = nil;
    [self.wkWebView removeFromSuperview];
    self.wkWebView = nil;
    [super dealloc];
}
- (void)setVisible:(bool)visible {
    self.wkWebView.hidden = !visible;
}

- (void)setBounces:(bool)bounces {
    
}

- (void)setFrameWithX:(float)x y:(float)y width:(float)width height:(float)height {
    if (!self.wkWebView) {
        [self setupWebView];
    }
    
    CGRect newFrame = CGRectMake(x, y, width, height);
    if (!CGRectEqualToRect(self.wkWebView.frame, newFrame)) {
        self.wkWebView.frame = CGRectMake(x, y, width, height);
    }
}

- (void)setJavascriptInterfaceScheme:(const std::string &)scheme {
    
}

- (void)loadData:(const std::string &)data MIMEType:(const std::string &)MIMEType textEncodingName:(const std::string &)encodingName baseURL:(const std::string &)baseURL {
    if (!self.wkWebView) {
        [self setupWebView];
    }
    
}

- (void)loadHTMLString:(const std::string &)string baseURL:(const std::string &)baseURLStr {
    if (!self.wkWebView) {
        [self setupWebView];
    }
    NSString *htmlStr = [NSString stringWithUTF8String:string.c_str()];
    NSURL* baseUrl = [NSURL URLWithString: [NSString stringWithUTF8String: baseURLStr.c_str()]];
    [self.wkWebView loadHTMLString:htmlStr baseURL:baseUrl];
}

- (void)loadUrl:(const std::string &)urlString cleanCachedData:(BOOL) needCleanCachedData {
    if (!self.wkWebView) {
        [self setupWebView];
    }
    NSURL* url = [NSURL URLWithString: [NSString stringWithUTF8String: urlString.c_str()]];
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL: url];

    [self.wkWebView loadRequest:request];
}

- (void)loadFile:(const std::string &)filePath {
    if (!self.wkWebView) {
        [self setupWebView];
    }
    NSURL* fileUrl = [NSURL URLWithString: [NSString stringWithUTF8String: filePath.c_str()]];
    [self.wkWebView loadFileURL:fileUrl allowingReadAccessToURL:fileUrl];
}

- (void)stopLoading {
    if (!self.wkWebView) {
        [self setupWebView];
    }
    [self.wkWebView stopLoading];
}

- (void)reload {
    if (!self.wkWebView) {
        [self setupWebView];
    }
    [self.wkWebView reload];
}

- (void)evaluateJS:(const std::string &)js {
    [self.wkWebView evaluateJavaScript:[NSString stringWithUTF8String: js.c_str()] completionHandler:nil];
}

- (void)goBack {
    [self.wkWebView goBack];
}

- (void)goForward {
    if (!self.wkWebView) {
        [self setupWebView];
    }
    [self.wkWebView goForward];
}

- (void)setScalesPageToFit:(const bool)scalesPageToFit {
    
}
@end


namespace cocos2d {
    namespace experimental {
        namespace ui{
            
            WebViewImpl::WebViewImpl(WebView *webView)
            {
                _uiWebViewWrapper = [UIWebViewWrapper webViewWrapper];
                [_uiWebViewWrapper retain];
                this->_webView = webView;
                
                _uiWebViewWrapper.shouldStartLoading = [this](std::string url) {
                    if (this->_webView->_onShouldStartLoading) {
                        return this->_webView->_onShouldStartLoading(this->_webView, url);
                    }
                    return true;
                };
                _uiWebViewWrapper.didFinishLoading = [this](std::string url) {
                    if (this->_webView->_onDidFinishLoading) {
                        this->_webView->_onDidFinishLoading(this->_webView, url);
                    }
                };
                _uiWebViewWrapper.didFailLoading = [this](std::string url) {
                    if (this->_webView->_onDidFailLoading) {
                        this->_webView->_onDidFailLoading(this->_webView, url);
                    }
                };
                _uiWebViewWrapper.onJsCallback = [this](std::string url) {
                    if (this->_webView->_onJSCallback) {
                        this->_webView->_onJSCallback(this->_webView, url);
                    }
                };
            }
            
            WebViewImpl::~WebViewImpl(){
                [_uiWebViewWrapper release];
                _uiWebViewWrapper = nullptr;
            }
            
            void WebViewImpl::setJavascriptInterfaceScheme(const std::string &scheme) {
                [_uiWebViewWrapper setJavascriptInterfaceScheme:scheme];
            }
            
            void WebViewImpl::loadData(const Data &data,
                                       const std::string &MIMEType,
                                       const std::string &encoding,
                                       const std::string &baseURL) {
                
                std::string dataString(reinterpret_cast<char *>(data.getBytes()), static_cast<unsigned int>(data.getSize()));
                [_uiWebViewWrapper loadData:dataString MIMEType:MIMEType textEncodingName:encoding baseURL:baseURL];
            }
            
            void WebViewImpl::loadHTMLString(const std::string &string, const std::string &baseURL) {
                [_uiWebViewWrapper loadHTMLString:string baseURL:baseURL];
            }
            
            void WebViewImpl::loadURL(const std::string &url) {
                this->loadURL(url, false);
            }
            
            void WebViewImpl::loadURL(const std::string &url, bool cleanCachedData) {
                [_uiWebViewWrapper loadUrl:url cleanCachedData:cleanCachedData];
            }
            
            void WebViewImpl::loadFile(const std::string &fileName) {
                auto fullPath = cocos2d::FileUtils::getInstance()->fullPathForFilename(fileName);
                [_uiWebViewWrapper loadFile:fullPath];
            }
            
            void WebViewImpl::stopLoading() {
                [_uiWebViewWrapper stopLoading];
            }
            
            void WebViewImpl::reload() {
                [_uiWebViewWrapper reload];
            }
            
            bool WebViewImpl::canGoBack() {
                return _uiWebViewWrapper.canGoBack;
            }
            
            bool WebViewImpl::canGoForward() {
                return _uiWebViewWrapper.canGoForward;
            }
            
            void WebViewImpl::goBack() {
                [_uiWebViewWrapper goBack];
            }
            
            void WebViewImpl::goForward() {
                [_uiWebViewWrapper goForward];
            }
            
            void WebViewImpl::evaluateJS(const std::string &js) {
                [_uiWebViewWrapper evaluateJS:js];
            }
            
            void WebViewImpl::setBounces(bool bounces) {
                [_uiWebViewWrapper setBounces:bounces];
            }
            
            void WebViewImpl::setScalesPageToFit(const bool scalesPageToFit) {
                [_uiWebViewWrapper setScalesPageToFit:scalesPageToFit];
            }
            
            void WebViewImpl::draw(cocos2d::Renderer *renderer, cocos2d::Mat4 const &transform, uint32_t flags) {
                if (flags & cocos2d::Node::FLAGS_TRANSFORM_DIRTY) {
                    
                    auto director = cocos2d::Director::getInstance();
                    auto glView = director->getOpenGLView();
                    auto frameSize = glView->getFrameSize();
                    
                    auto scaleFactor = glView->getContentScaleFactor();
                    
                    auto winSize = director->getWinSize();
                    
                    auto leftBottom = this->_webView->convertToWorldSpace(cocos2d::Vec2::ZERO);
                    auto rightTop = this->_webView->convertToWorldSpace(cocos2d::Vec2(this->_webView->getContentSize().width, this->_webView->getContentSize().height));
                    
                    auto x = (frameSize.width / 2 + (leftBottom.x - winSize.width / 2) * glView->getScaleX()) / scaleFactor;
                    auto y = (frameSize.height / 2 - (rightTop.y - winSize.height / 2) * glView->getScaleY()) / scaleFactor;
                    auto width = (rightTop.x - leftBottom.x) * glView->getScaleX() / scaleFactor;
                    auto height = (rightTop.y - leftBottom.y) * glView->getScaleY() / scaleFactor;
                    
                    [_uiWebViewWrapper setFrameWithX:x
                                                   y:y
                                               width:width
                                              height:height];
                }
            }
            
            void WebViewImpl::setVisible(bool visible){
                [_uiWebViewWrapper setVisible:visible];
            }
            
        } // namespace ui
    } // namespace experimental
} //namespace cocos2d

#endif