//
//  SCHViewController.m
//  SwingingChicken
//
//  Created by Josh Berlin on 9/25/13.
//  Copyright (c) 2013 josh. All rights reserved.
//

#import "SCHViewController.h"

#import "UIView+FLKAutoLayout.h"

@interface SCHViewController ()<UICollisionBehaviorDelegate>
@property(nonatomic, strong) UIButton *swingChickenButton;
@property(nonatomic, strong) UIImageView *chickenImageView;
@property(nonatomic, strong) UIImageView *wafflesImageView;
@property(nonatomic, strong) UIDynamicItemBehavior *bodyBehavior;
@property(nonatomic, strong) UIGravityBehavior *gravityBehavior;
@property(nonatomic, strong) UIDynamicAnimator *modalDynamicAnimator;
@property(nonatomic, strong) UIAttachmentBehavior *chickenCornerAttachmentBehavior;
@property(nonatomic, strong) UIAttachmentBehavior *wafflesTopAttachmentBehavior;
@property(nonatomic, strong) UICollisionBehavior *catCollisionBehavior;
@property(nonatomic, assign) BOOL chickenSwinging;
@property(nonatomic, assign) BOOL wafflesDropping;
@end

@implementation SCHViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    _swingChickenButton = [self newSwingChickenButton];
    _chickenImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chicken"]];
    _wafflesImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"waffles"]];
  }
  return self;
}

- (UIButton *)newSwingChickenButton {
  UIButton *swingChickenButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [swingChickenButton setTitle:@"swing chicken" forState:UIControlStateNormal];
  [swingChickenButton addTarget:self
                         action:@selector(chickenButtonPressed:)
               forControlEvents:UIControlEventTouchUpInside];
  return swingChickenButton;
}

- (void)loadView {
  self.view = [[UIView alloc] init];
  self.view.backgroundColor = [UIColor orangeColor];
  [self.view addSubview:self.swingChickenButton];
  [self applyConstraints];
}

- (void)applyConstraints {
  [self.swingChickenButton alignLeading:@"20" trailing:@"-20" toView:self.view];
  [self.swingChickenButton alignBottomEdgeWithView:self.view predicate:@"-20"];
}

- (void)chickenButtonPressed:(id)sender {
  if (self.chickenSwinging) {
    if (self.wafflesDropping) {
      [self.swingChickenButton setTitle:@"swing chicken" forState:UIControlStateNormal];
      [self reset];
    } else {
      [self.swingChickenButton setTitle:@"reset chicken & waffles" forState:UIControlStateNormal];
      [self dropWaffles];
    }
  } else {
    [self.swingChickenButton setTitle:@"drop waffles" forState:UIControlStateNormal];
    [self swingChicken];
  }
}

- (CGPoint)chickenSwingOrigin {
  return CGPointMake(CGRectGetMaxX(self.view.frame) + 300, 0);
}

- (CGPoint)wafflesDropOrigin {
  return CGPointMake(self.view.center.x, -75);
}

- (void)reset {
  self.swingChickenButton.enabled = NO;
  [self.modalDynamicAnimator removeAllBehaviors];
  [self resetChicken];
  [self resetWaffles];
}

- (void)resetChicken {
  self.chickenSwinging = NO;
  [UIView animateWithDuration:1.0f
                   animations:^{
                       self.chickenImageView.center = [self chickenSwingOrigin];
                   }
                   completion:^(BOOL finished) {
                       [self.chickenImageView removeFromSuperview];
                   }];
}

- (void)swingChicken {
  self.chickenSwinging = YES;
  
  [self.view addSubview:self.chickenImageView];
  self.chickenImageView.center = [self chickenSwingOrigin];
  
  self.modalDynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
  
  self.bodyBehavior = [[UIDynamicItemBehavior alloc] init];
  self.bodyBehavior.allowsRotation = NO;
  [self.bodyBehavior addItem:self.chickenImageView];
  
  NSArray *gravityItems = @[self.chickenImageView];
  self.gravityBehavior = [[UIGravityBehavior alloc] initWithItems:gravityItems];
  self.gravityBehavior.magnitude = 4.0f;
  
  self.chickenCornerAttachmentBehavior =
      [[UIAttachmentBehavior alloc] initWithItem:self.chickenImageView
                                attachedToAnchor:CGPointMake(self.view.center.x, 0.0f)];
  self.chickenCornerAttachmentBehavior.length = 200.0f;
  self.chickenCornerAttachmentBehavior.damping = 0.3f;
  self.chickenCornerAttachmentBehavior.frequency = 1.15f;
  
  [self.modalDynamicAnimator addBehavior:self.bodyBehavior];
  [self.modalDynamicAnimator addBehavior:self.gravityBehavior];
  [self.modalDynamicAnimator addBehavior:self.chickenCornerAttachmentBehavior];
}

- (void)resetWaffles {
  self.wafflesDropping = NO;
  [UIView animateWithDuration:1.0f
                   animations:^{
                       self.wafflesImageView.center = [self wafflesDropOrigin];
                   }
                   completion:^(BOOL finished) {
                       [self.wafflesImageView removeFromSuperview];
                       self.swingChickenButton.enabled = YES;
                   }];
}

- (void)dropWaffles {
  self.wafflesDropping = YES;
  
  [self.view addSubview:self.wafflesImageView];
  self.wafflesImageView.center = [self wafflesDropOrigin];
  
  [self.modalDynamicAnimator removeBehavior:self.gravityBehavior];
  NSArray *gravityItems = @[self.chickenImageView, self.wafflesImageView];
  self.gravityBehavior = [[UIGravityBehavior alloc] initWithItems:gravityItems];
  self.gravityBehavior.magnitude = 4.0f;
  
  [self.bodyBehavior addItem:self.wafflesImageView];
  
  self.wafflesTopAttachmentBehavior =
      [[UIAttachmentBehavior alloc] initWithItem:self.wafflesImageView
                                attachedToAnchor:[self wafflesDropOrigin]];
  self.wafflesTopAttachmentBehavior.length = 250.0f;
  self.wafflesTopAttachmentBehavior.damping = 0.3f;
  self.wafflesTopAttachmentBehavior.frequency = 1.15f;
  
  [self.modalDynamicAnimator addBehavior:self.wafflesTopAttachmentBehavior];
  
  self.catCollisionBehavior =
      [[UICollisionBehavior alloc] initWithItems:@[self.wafflesImageView, self.chickenImageView]];
  self.catCollisionBehavior.collisionDelegate = self;
  
  [self.modalDynamicAnimator addBehavior:self.gravityBehavior];
  [self.modalDynamicAnimator addBehavior:self.catCollisionBehavior];
}

- (void)collisionBehavior:(UICollisionBehavior*)behavior beganContactForItem:(id <UIDynamicItem>)item1 withItem:(id <UIDynamicItem>)item2 atPoint:(CGPoint)p {
  [self.modalDynamicAnimator removeBehavior:self.chickenCornerAttachmentBehavior];
  behavior.collisionDelegate = nil;
  double delayInSeconds = 1.0f;
  dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
  dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    [UIView animateWithDuration:0.25
                     animations:^{
                       self.chickenImageView.center = [self chickenSwingOrigin];
                     }
                     completion:^(BOOL finished) {
                       [self.modalDynamicAnimator addBehavior:self.chickenCornerAttachmentBehavior];
                     }];
  });
}

@end
