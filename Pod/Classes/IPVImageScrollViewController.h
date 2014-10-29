@import UIKit;

@class IPVImageScrollViewController;

@protocol IPVImageScrollViewControllerDataSource <NSObject>
- (BOOL)imageScrollViewController:(IPVImageScrollViewController *)imageScrollViewController
                      imageForKey:(id)key
                completionHandler:(void (^)(UIImage *image))completionHandler;
@end

@interface IPVImageScrollViewController : UIViewController<UIScrollViewDelegate>

+(instancetype)imageScrollViewControllerForKey:(id)key
                                    dataSource:(id<IPVImageScrollViewControllerDataSource>)dataSource;

-(instancetype)initWithKey:(id)key
                dataSource:(id<IPVImageScrollViewControllerDataSource>)dataSource;

@property(nonatomic, readonly) id key;

@property(nonatomic, readonly) UIImage *image;

@property(nonatomic, assign, readonly) id<IPVImageScrollViewControllerDataSource>dataSource;

-(void)toggleZoom:(CGPoint)center;

@end
