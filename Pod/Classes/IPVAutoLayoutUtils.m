#import "IPVAutoLayoutUtils.h"

NSArray *IPVPinEdgesToSuperview(UIView *view, UIView *superview) {
    return @[
             IPVEqualsAttribute(view, superview, NSLayoutAttributeTop),
             IPVEqualsAttribute(view, superview, NSLayoutAttributeRight),
             IPVEqualsAttribute(view, superview, NSLayoutAttributeBottom),
             IPVEqualsAttribute(view, superview, NSLayoutAttributeLeft)
             ];
}

NSArray *IPVCenterInSuperview(UIView *view, UIView *superview) {
    return @[
             IPVEqualsAttribute(view, superview, NSLayoutAttributeCenterX),
             IPVEqualsAttribute(view, superview, NSLayoutAttributeCenterY)
             ];
}

NSLayoutConstraint *IPVEqualsAttribute(UIView *firstItem,
                                       UIView *secondItem,
                                       NSLayoutAttribute attribute)
{
    return [NSLayoutConstraint constraintWithItem:firstItem
                                        attribute:attribute
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:secondItem
                                        attribute:attribute
                                       multiplier:1
                                         constant:0];
}
