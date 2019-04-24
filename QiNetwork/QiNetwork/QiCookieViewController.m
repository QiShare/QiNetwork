//
//  QiCookieViewController.m
//  QiNetwork
//
//  Created by wangyongwang on 2019/4/16.
//  Copyright © 2019年 QiShare. All rights reserved.
//
/**
 感谢：
 * https://www.jianshu.com/p/d2c478bbcca5
 * https://mp.weixin.qq.com/s/rhYKLIbXOsUJC_n6dt9UfA
 */

#import "QiCookieViewController.h"
#import <AFHTTPSessionManager.h>
#import <WebKit/WebKit.h>

static NSString *const kJianshuDomain = @".jianshu.com";
static NSString *const kJuejinDomain = @".juejin.im";

@interface QiCookieViewController ()<WKNavigationDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) WKWebView *wkWebView;

@end

@implementation QiCookieViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)setupUI {
    
    CGFloat screenWidth = CGRectGetWidth(self.view.frame);
    CGFloat height = CGRectGetHeight(self.view.frame) * 0.12;
    CGFloat verticalY = CGRectGetHeight(self.view.frame) * 0.15;
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    UIButton *hideButtonsBtn = [[UIButton alloc] init];
    [hideButtonsBtn setTitle:@"hideBtn" forState:UIControlStateNormal];
    hideButtonsBtn.backgroundColor = [UIColor darkGrayColor];
    [hideButtonsBtn addTarget:self action:@selector(hideButtons:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:hideButtonsBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    WKUserContentController *userContentController = [WKUserContentController new];
    NSString *cookieSource = [NSString stringWithFormat:@"document.cookie = 'QiShareAuth1=QiShareAuth1';document.cookie = 'QiShareAuth2=QiShareAuth2';"];
    WKUserScript *cookieScript = [[WKUserScript alloc] initWithSource:cookieSource injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [userContentController addUserScript:cookieScript];
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.userContentController = userContentController;
    
    NSURL *juejinUrl = [NSURL URLWithString:@"https://www.jianshu.com"];
    juejinUrl = [NSURL URLWithString:@"https://juejin.im"];
    NSMutableURLRequest *mJuejinRequest = [[NSMutableURLRequest alloc] initWithURL:juejinUrl];
    [mJuejinRequest addValue:@"QiShareAuth1=QiShareAuth1;QiShareAuth2=QiShareAuth2" forHTTPHeaderField:@"Cookie"];
    WKWebView *wkWebV  = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    _wkWebView = wkWebV;
    
    [_wkWebView loadRequest:mJuejinRequest];
    wkWebV.navigationDelegate = self;
    
    [self.view addSubview:wkWebV];
    
    UIWebView *webV = [[UIWebView alloc] init];
    webV.frame = self.view.bounds;
    webV.userInteractionEnabled = YES;
    [self.view addSubview:webV];
    webV.scalesPageToFit = YES;
    _webView = webV;
    
    UIButton *urlSessionLoadRequestBtn = [[UIButton alloc] init];
    urlSessionLoadRequestBtn.frame = CGRectMake(.0, .0, screenWidth, height);
    urlSessionLoadRequestBtn.backgroundColor = [UIColor lightGrayColor];
    
    [urlSessionLoadRequestBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [urlSessionLoadRequestBtn setTitle:@"urlSessionLoadRequestBtn 请求加载" forState:UIControlStateNormal];
    [self.view addSubview:urlSessionLoadRequestBtn];
    [urlSessionLoadRequestBtn addTarget:self action:@selector(urlSessionLoadRequestButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *afnLoadRequestBtn = [[UIButton alloc] initWithFrame:CGRectMake(.0, verticalY * 1, screenWidth, height)];
    afnLoadRequestBtn.backgroundColor = [UIColor lightGrayColor];
    [afnLoadRequestBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [afnLoadRequestBtn setTitle:@"afnLoadRequestBtn 请求加载" forState:UIControlStateNormal];
    [self.view addSubview:afnLoadRequestBtn];
    [afnLoadRequestBtn addTarget:self action:@selector(afnLoadRequestButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *loadUIWebViewBtn = [[UIButton alloc] initWithFrame:CGRectMake(.0, verticalY * 2, screenWidth, height)];
    loadUIWebViewBtn.backgroundColor = [UIColor lightGrayColor];
    [loadUIWebViewBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [loadUIWebViewBtn setTitle:@"UIWebView加载" forState:UIControlStateNormal];
    [self.view addSubview:loadUIWebViewBtn];
    [loadUIWebViewBtn addTarget:self action:@selector(loadUIWebViewButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *loadWkWebViewBtn = [[UIButton alloc] initWithFrame:CGRectMake(.0, verticalY * 3, screenWidth, height)];
    loadWkWebViewBtn.backgroundColor = [UIColor lightGrayColor];
    [loadWkWebViewBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [loadWkWebViewBtn setTitle:@"WKWebView加载" forState:UIControlStateNormal];
    [self.view addSubview:loadWkWebViewBtn];
    [loadWkWebViewBtn addTarget:self action:@selector(loadWkWebViewButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *exchangeUIWebViewWithWkWebViewIndexBtn = [[UIButton alloc] initWithFrame:CGRectMake(.0, verticalY * 4, screenWidth, height)];
    [exchangeUIWebViewWithWkWebViewIndexBtn setTitle:@"交换UIWebWKWebViewIndex" forState:UIControlStateNormal];
    exchangeUIWebViewWithWkWebViewIndexBtn.backgroundColor = [UIColor darkGrayColor];
    [self.view addSubview:exchangeUIWebViewWithWkWebViewIndexBtn];
    [exchangeUIWebViewWithWkWebViewIndexBtn addTarget:self action:@selector(exchangeWebWKWebButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *recoverUIWebViewWithWkWebViewIndexBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, verticalY * 5, screenWidth, height)];
    recoverUIWebViewWithWkWebViewIndexBtn.backgroundColor = [UIColor lightGrayColor];
    [recoverUIWebViewWithWkWebViewIndexBtn setTitle:@"重置UIWebWKWebView显示内容" forState:UIControlStateNormal];
    [self.view addSubview:recoverUIWebViewWithWkWebViewIndexBtn];
    [recoverUIWebViewWithWkWebViewIndexBtn addTarget:self action:@selector(resetWebWKWebContentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
}

//! 隐藏按钮
- (void)hideButtons:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    
    for (UIView *subV in self.view.subviews) {
        if ([subV isKindOfClass:[UIButton class]]) {
            subV.hidden = sender.selected;
        }
    }
}

//! 重置webView的显示内容
- (void)resetWebWKWebContentButtonClicked:(UIButton *)sender {
    
    [self.webView loadHTMLString:@"" baseURL:nil];
    [self.wkWebView loadHTMLString:@"" baseURL:nil];
}

//! 调整WKWebView和UIWebView的层级索引
- (void)exchangeWebWKWebButtonClicked:(UIButton *)sender {
    
    [self.view exchangeSubviewAtIndex:2 withSubviewAtIndex:3];
}

//! 系统原生网络请求设置Cookie
- (void)urlSessionLoadRequestButtonClicked:(UIButton *)sender {
    
    self.title = @"urlSessionLoadRequest";
    [self systemRequestTakeCookie];
}

//! AFN网络请求设置cookie
- (void)afnLoadRequestButtonClicked:(UIButton *)sender {
    
    self.title = @"AFNLoadRequest";
    [self AFNRequestTakeCookie];
}

//! WebView加载 并设置Cookie
- (void)loadUIWebViewButtonClicked:(UIButton *)sender {
    
    self.title = @"LoadUIWebView";
    [self webViewInjectCookie];
}

//! WKWebView加载并设置Cookie
- (void)loadWkWebViewButtonClicked:(UIButton *)sender {
    
    self.title = @"LoadWKWebView";
    [self wkWebViewInjectCookie];
}

- (void)wkWebViewInjectCookie {
    
    NSURL *url = [NSURL URLWithString:@"https://juejin.im"];
    NSMutableURLRequest *mRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    // 某个请求的时候注入Cookie
    // [mRequest addValue:@"QiShareNameWK1=QiShareValueWK1;QiShareNameWK2=QiShareValueWK2;QiShareNameWK3=QiShareValueWK3" forHTTPHeaderField:@"Cookie"];
    [_wkWebView loadRequest:mRequest];
}

//! UIWebView注入Cookie
- (void)webViewInjectCookie {
    
    NSURL *url = [NSURL URLWithString:@"https://www.jianshu.com"];
    url = [NSURL URLWithString:@"https://www.jianshu.com/p/1174d1dbe650"];
    [self setCookieWithName:@"local" cookieValue:@"zh-TW" cookiePath:@"/" cookieDomain:kJianshuDomain];
    [self setCookieWithName:@"QiShareToken" cookieValue:@"QiShareTokenValue" cookiePath:@"/" cookieDomain:kJianshuDomain];
    [self setCookieWithName:@"QiShareKey" cookieValue:@"QiShareValue" cookiePath:@"/" cookieDomain:kJianshuDomain];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [_webView loadRequest:request];
}

//! 系统网络请求携带Cookie
- (void)systemRequestTakeCookie2 {
    
    NSURL *url = [NSURL URLWithString:@"https://www.jianshu.com"];
    NSMutableURLRequest *mRequest = [NSMutableURLRequest requestWithURL:url];
    mRequest.HTTPMethod = @"GET";
    [mRequest setValue:@"QiShareName=QiShareValue;QiShareToken=QiShareTokenValue" forHTTPHeaderField:@"cookie"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:mRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    }];
    [dataTask resume];
}


//! 系统网络请求携带Cookie
- (void)systemRequestTakeCookie {
    
    NSURL *url = [NSURL URLWithString:@"https://www.jianshu.com"];
    NSMutableURLRequest *mRequest = [NSMutableURLRequest requestWithURL:url];
    mRequest.HTTPMethod = @"GET";
    [mRequest setValue:@"QiShareName=QiShareValue;QiShareToken=QiShareTokenValue" forHTTPHeaderField:@"cookie"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:mRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data && !error) {
            NSString *responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.webView loadHTMLString:responseStr baseURL:nil];
            });
            NSLog(@"简书Response：%@", responseStr);
        } else {
            NSLog(@"简书ResponseError：%@", error);
        }
    }];
    [dataTask resume];
}

//! AFN请求携带Cookie
- (void)AFNRequestTakeCookie2 {
    
    NSString *urlString = @"https://juejin.im";
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [sessionManager.requestSerializer setValue:@"QiShareNameAFN=QiShareValueAFN;QiShareTokenAFN=QiShareTokenValueAFN" forHTTPHeaderField:@"cookie"];
    [sessionManager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    }];
}

//! AFN请求携带Cookie
- (void)AFNRequestTakeCookie {
    
    NSString *urlString = @"https://juejin.im";
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [sessionManager.requestSerializer setValue:@"QiShareNameAFN=QiShareValueAFN;QiShareTokenAFN=QiShareTokenValueAFN" forHTTPHeaderField:@"cookie"];
    [sessionManager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSData class]]) {
            NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSLog(@"掘金请求响应：%@", responseStr);
            [self.wkWebView loadHTMLString:responseStr baseURL:nil];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error) {
            [self.wkWebView loadHTMLString:@"加载掘金加载错误" baseURL:nil];
            NSLog(@"掘金请求出错：%@", error);
        }
    }];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    if (!navigationAction.targetFrame) {
        [webView loadRequest:navigationAction.request];
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

//! 生成指定cookieName cookieValue cookiePath cookieDomain 的NSHTTPCookie 实例
- (NSHTTPCookie *)cookieWithName:(NSString *)name cookieValue:(NSString *)value  cookiePath:(NSString *)path cookieDomain:(NSString *)domain {
    
    NSDictionary *keyProperties = @{
                                    NSHTTPCookieName: name,
                                    NSHTTPCookieValue: value,
                                    NSHTTPCookiePath: path,
                                    NSHTTPCookieDomain: domain
                                    };
    
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:keyProperties];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    return cookie;
}

//! 设置 （生成指定cookieName cookieValue cookiePath cookieDomain 的NSHTTPCookie 实例） 到NSHTTPCookieStorage
- (NSHTTPCookie *)setCookieWithName:(NSString *)name cookieValue:(NSString *)value  cookiePath:(NSString *)path cookieDomain:(NSString *)domain {
    
    if (!name || !value || !path || !domain) {
        return nil;
    }
    NSHTTPCookie *cookie = [self cookieWithName:name cookieValue:value cookiePath:path cookieDomain:domain];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    
    return cookie;
}


- (void)others {
    
    // _wkWebView.configuration.websiteDataStore.httpCookieStore 的方式并没有生效
    /** // Xcode10.1 iPhone XR 模拟器测试无效
     if (@available(iOS 11.0, *)) {
     WKHTTPCookieStore *wkCookieStore = _wkWebView.configuration.websiteDataStore.httpCookieStore;
     [wkCookieStore setCookie:[self cookieWithName:@"QiShareAuth1" cookieValue:@"QiShareAuth1" cookiePath:@"/" cookieDomain:kJuejinDomain] completionHandler:^{
     
     }];
     [wkCookieStore setCookie:[self cookieWithName:@"QiShareAuth2" cookieValue:@"QiShareAuth2" cookiePath:@"/" cookieDomain:kJuejinDomain] completionHandler:^{
     
     }];
     } else {
     // Fallback on earlier versions
     }
     */
    
    /** // 遍历Cookies
     if (@available(iOS 11.0, *)) {
     [_wkWebView.configuration.websiteDataStore.httpCookieStore getAllCookies:^(NSArray<NSHTTPCookie *> * _Nonnull cookiesArr) {
     for (NSHTTPCookie *cookie in cookiesArr) {
     NSLog(@"name：%@--value：%@", cookie.name, cookie.value);
     }
     }];
     }
     */
}

@end
