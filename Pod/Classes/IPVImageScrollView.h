@import UIKit;

@interface IPVImageScrollView : UIScrollView

- (instancetype)initWithImage:(UIImage *)image;

- (void)toggleZoom:(CGPoint)center;

@end
