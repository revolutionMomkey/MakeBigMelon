//
//  DJNCustomFruitView.h
//  MakeBigMelon
//
//  Created by 杜俊楠 on 2022/7/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger) {
    
    fruit_melon = 1,
    fruit_grapefruit = 2,
    fruit_orange = 3,
    fruit_apple = 4,
    fruit_grape = 5,
    fruit_cherry = 6,
    
} fruitType;

@interface DJNCustomFruitView : UIView

@property (nonatomic) UIDynamicItemCollisionBoundsType collisionBoundsType;

@property (nonatomic,assign) fruitType currenFruitType;

@end

NS_ASSUME_NONNULL_END
