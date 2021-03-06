#if !__has_feature(objc_arc)
#error "ARC is required for this file"
#endif

#import "UIView+PCKNibHelpers.h"


@implementation NSLayoutConstraint (PCKNibHelpers)

- (NSLayoutConstraint *)constraintByReplacingView:(UIView *)viewToReplace withView:(UIView *)replacingView {
    UIView *firstItem = self.firstItem;
    UIView *secondItem = self.secondItem;

    if (self.firstItem == viewToReplace) {
        firstItem = replacingView;
    } else if (self.secondItem == viewToReplace) {
        secondItem = replacingView;
    }
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:firstItem
                                                                  attribute:self.firstAttribute
                                                                  relatedBy:self.relation
                                                                     toItem:secondItem
                                                                  attribute:self.secondAttribute
                                                                 multiplier:self.multiplier
                                                                   constant:self.constant];
    constraint.identifier = self.identifier;
    constraint.priority = self.priority;
    return constraint;
}

@end

@implementation UIView (PCKNibHelpers)

- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder {
    NSString *nibName = NSStringFromClass([self class]);
    if ([self.restorationIdentifier hasPrefix:@"placeholder"] && [[NSBundle bundleForClass:[self class]] pathForResource:nibName ofType:@"nib"]) {
        UINib *classNib = [UINib nibWithNibName:nibName bundle:[NSBundle bundleForClass:[self class]]];
        UIView *nibInstance = [[classNib instantiateWithOwner:nil options:nil] firstObject];
        nibInstance.translatesAutoresizingMaskIntoConstraints = NO;
        [nibInstance configureWithPlaceholderView:self];
        return nibInstance;
    }

    return self;
}

- (void)configureWithPlaceholderView:(UIView *)placeholderView {
    self.frame = placeholderView.frame;

    for (NSLayoutConstraint *constraint in placeholderView.constraints) {
        if ([placeholderView.subviews containsObject:constraint.firstItem] || [placeholderView.subviews containsObject:constraint.secondItem]) {
            continue;
        }

        [self addConstraint:[constraint constraintByReplacingView:placeholderView withView:self]];
    }

    for (NSLayoutConstraint *constraint in self.superview.constraints) {
        [placeholderView.superview addConstraint:[constraint constraintByReplacingView:placeholderView withView:self]];
    }
}

@end
