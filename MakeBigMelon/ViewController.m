//
//  ViewController.m
//  MakeBigMelon
//
//  Created by 杜俊楠 on 2022/7/8.
//

#import "ViewController.h"
#import "DJNCustomFruitView.h"
#import <AVFoundation/AVFoundation.h>

#define seperateLineY 172

@interface ViewController ()<UIDynamicAnimatorDelegate,UICollisionBehaviorDelegate>

@property (nonatomic,strong) UIView *ballView;

@property (nonatomic,strong) UIDynamicAnimator *animator;

@property (nonatomic,strong) UIGravityBehavior *gravity;

@property (nonatomic,strong) UICollisionBehavior *collision;

@property (nonatomic,copy) NSString *scores;

@property (nonatomic,strong) UILabel *scoresLab;
//水果等级,1-6,1最大,6最小,初始化为6,随着合成
@property (nonatomic,assign) NSInteger maxFruitLevel;

@property (nonatomic,strong) AVAudioPlayer *player;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self setData];
    [self setUI];
    
    [self addFruitInView];
}

- (void)setUI {
    UIImage *image = [UIImage imageNamed:@"Background"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    
    UIButton *restartBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [restartBtn setTitle:@"重新开始" forState:UIControlStateNormal];
    [restartBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    restartBtn.frame = CGRectMake(20, 64, 80, 35);
    [restartBtn addTarget:self action:@selector(restartAction) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:restartBtn];
    
    //添加按钮可以手动添加一个fruitView,方便调试用,实际游戏中不会用到
//    UIButton *addFruitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [addFruitBtn setTitle:@"添加" forState:UIControlStateNormal];
//    [addFruitBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    addFruitBtn.frame = CGRectMake(20, 104, 60, 35);
//    [addFruitBtn addTarget:self action:@selector(addFruitInView) forControlEvents:UIControlEventTouchDown];
//    [self.view addSubview:addFruitBtn];
    
    self.scoresLab = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-120, 64, 100, 35)];
    self.scoresLab.text = self.scores;
    self.scoresLab.textAlignment = NSTextAlignmentRight;
    self.scoresLab.textColor = [UIColor blackColor];
    [self.view addSubview:self.scoresLab];
    
    UILabel *tips = [[UILabel alloc] initWithFrame:CGRectMake(0, seperateLineY-10, self.view.bounds.size.width, 50)];
    tips.text = @"←左右拖动水果位置,松手释放,完全停止后生成新的水果→";
    tips.textColor = [UIColor grayColor];
    tips.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:tips];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 2)];
    lineView.center = CGPointMake(self.view.bounds.size.width/2, seperateLineY);
    lineView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:lineView];
    
    
}

- (void)setData {
    self.scores = @"0";
    self.maxFruitLevel = 6;
    [self.player play];
}

- (void)addFruitInView {

    UIView *fruitView = [self makeFruitWith:0];
    [self.view addSubview:fruitView];
    fruitView.center = CGPointMake(self.view.bounds.size.width/2, 150);
}

- (void)fruitUpgradeAt:(CGPoint)point withFruitType:(fruitType)type {
    fruitType newType;
    if (type == 1) {
//        NSLog(@"一个大西瓜");
        newType = type;
    }
    else {
        newType = type-1;
        if (self.maxFruitLevel >= type) {
            self.maxFruitLevel--;
        }
    }
    DJNCustomFruitView *fruitView = [self makeFruitWith:newType];
    [self.view addSubview:fruitView];
    fruitView.center = CGPointMake(point.x,point.y);
    [self.gravity addItem:fruitView];
    [self.collision addItem:fruitView];
    [self.animator updateItemUsingCurrentState:fruitView];
    [self.animator updateItemUsingCurrentState:fruitView];
    int _score = 720/type;
    self.scores = [NSString stringWithFormat:@"%d",[self.scores intValue]+_score];
    self.scoresLab.text = self.scores;
}

- (void)restartAction {
    self.scores = @"0";
    self.scoresLab.text = self.scores;
    for (DJNCustomFruitView *view in self.gravity.items) {
        [view removeFromSuperview];
        [self.gravity removeItem:view];
        [self.collision removeItem:view];
    }
}

- (void)panAction:(UIPanGestureRecognizer *)pan {

    CGPoint point = [pan translationInView:pan.view];
    static CGPoint center;
    if (pan.state == UIGestureRecognizerStateBegan) {
        //UIGestureRecognizerStateBegan,         //拖动开始
        //刚开始的时候,记录视图的中心点
        center = pan.view.center;
    }
    else if (pan.state == UIGestureRecognizerStateChanged) {
        //UIGestureRecognizerStateChanged,       //拖动过程中
        //改变中心点位置
        pan.view.center = CGPointMake(center.x + point.x, center.y);
        if (pan.view.center.x < -10) {
            pan.view.center = CGPointMake(center.x + 15, center.y);
        }
        else if (pan.view.center.x > self.view.bounds.size.width + 10){
            pan.view.center = CGPointMake(center.x - 15, center.y);
        }
    }
    else if (pan.state == UIGestureRecognizerStateEnded) {
        //UIGestureRecognizerStateEnded,         //拖动结束
        NSLog(@"%@",pan);
        if (pan.view.center.x < -1) {
            pan.view.center = CGPointMake(center.x + 15, center.y);
        }
        else if (pan.view.center.x > self.view.bounds.size.width + 1){
            pan.view.center = CGPointMake(center.x - 15, center.y);
        }
        [self makeFruitFullWith:(DJNCustomFruitView *)pan.view];
        [pan.view removeGestureRecognizer:pan];
    }
}

- (void)makeFruitFullWith:(DJNCustomFruitView *)fruitView {
    [self.gravity addItem:fruitView];
    [self.collision addItem:fruitView];
    [self.animator updateItemUsingCurrentState:fruitView];
    [self.animator updateItemUsingCurrentState:fruitView];
}

- (AVAudioPlayer *)player {
    if (_player == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Garoad - last stop for the night" ofType:@"mp3"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        _player = [[AVAudioPlayer alloc] initWithData:data error:nil];
        _player.numberOfLoops = -1;
        [self.player prepareToPlay];
    }
    return _player;
}

#pragma mark -UICollisionBehaviorDelegate-

- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id <UIDynamicItem>)item1 withItem:(id <UIDynamicItem>)item2 atPoint:(CGPoint)p {
//    NSLog(@"\n 开始碰撞--\n item1=%@, \n item2=%@, \n p.x=%f,p.y=%f",item1,item2,p.x,p.y);
    if (item1.bounds.size.width == item2.bounds.size.width) {
        [self.gravity removeItem:item1];
        [self.gravity removeItem:item2];
        [self.collision removeItem:item1];
        [self.collision removeItem:item2];
        [self.animator addBehavior:self.gravity];
        [self.animator addBehavior:self.collision];
        DJNCustomFruitView *item1View = (DJNCustomFruitView *)item1;
        DJNCustomFruitView *item2View = (DJNCustomFruitView *)item2;
        [item1View removeFromSuperview];
        [item2View removeFromSuperview];
        [self fruitUpgradeAt:p withFruitType:(item1View.currenFruitType)];
    }
}

#pragma mark -UIDynamicAnimatorDelegate-

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator {
    NSArray *array = [self.animator itemsInRect:CGRectMake(0, 0, self.view.bounds.size.width, seperateLineY)];
//    NSLog(@"--->%@",array);
    if (array.count) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"你输了" message:[NSString stringWithFormat:@"最终得分:%@",self.scores] preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"再来一局" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self restartAction];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        [self addFruitInView];
    }
}

#pragma mark -lazy-

- (UIDynamicAnimator *)animator {
    if (!_animator) {
        _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
        _animator.delegate = self;
        [_animator addBehavior:self.collision];
        [_animator addBehavior:self.gravity];
    }
    return _animator;
}

- (UIGravityBehavior *)gravity {
    if (!_gravity) {
        _gravity = [[UIGravityBehavior alloc] init];
        _gravity.magnitude = 2;
        _gravity.angle = M_PI/2;
    }
    return _gravity;
}

- (UICollisionBehavior *)collision {
    if (!_collision) {
        _collision = [[UICollisionBehavior alloc] init];
        _collision.translatesReferenceBoundsIntoBoundary = YES;
        _collision.collisionMode = UICollisionBehaviorModeEverything;
        _collision.collisionDelegate = self;
    }
    return  _collision;
}

#pragma mark -水果工厂-

- (DJNCustomFruitView *)makeFruitWith:(fruitType)type {
    int _fruitDiameter = 0;
    fruitType _currenFruitType;
    UIColor *fruitColor;
    switch (type) {
        case 0:{
            int arcNum = arc4random()%6+1;
            if (arcNum < self.maxFruitLevel) {
                return [self makeFruitWith:6];
            }
            else {
                return [self makeFruitWith:arcNum];
            }
        }break;
        case 1:{
            _fruitDiameter = 190;
            _currenFruitType = 1;
            fruitColor = [UIColor redColor];
        }break;
        case 2:{
            _fruitDiameter = 160;
            _currenFruitType = 2;
            fruitColor = [UIColor yellowColor];
        }break;
        case 3:{
            _fruitDiameter = 120;
            _currenFruitType = 3;
            fruitColor = [UIColor orangeColor];
        }break;
        case 4:{
            _fruitDiameter = 80;
            _currenFruitType = 4;
            fruitColor = [UIColor systemPinkColor];
        }break;
        case 5:{
            _fruitDiameter = 60;
            _currenFruitType = 5;
            fruitColor = [UIColor purpleColor];
        }break;
        case 6:{
            _fruitDiameter = 40;
            _currenFruitType = 6;
            fruitColor = [UIColor greenColor];
        }break;
        default:{
            _fruitDiameter = 40;
            _currenFruitType = 6;
        }break;
    }
    
    DJNCustomFruitView *fruitView = [self prototypeFruitView:_fruitDiameter];
    fruitView.currenFruitType = _currenFruitType;
    fruitView.backgroundColor = fruitColor;
    return fruitView;
}

- (DJNCustomFruitView *)prototypeFruitView:(int)fruitSize {
    DJNCustomFruitView *view = [[DJNCustomFruitView alloc] initWithFrame:CGRectMake(0, 0, fruitSize, fruitSize)];
    view.collisionBoundsType = UIDynamicItemCollisionBoundsTypeEllipse;
    view.layer.cornerRadius = fruitSize/2;
    view.backgroundColor = [UIColor grayColor];
    view.clipsToBounds = YES;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [view addGestureRecognizer:pan];
    view.userInteractionEnabled = YES;
    return view;
}

@end
