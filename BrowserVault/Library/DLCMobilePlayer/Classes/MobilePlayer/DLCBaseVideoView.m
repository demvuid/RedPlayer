//
//  DLCBaseVideoView.m
//  DLCMobilePlayer
//
//  Created by Linzh on 10/26/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "DLCBaseVideoView.h"
#import <MobileVLCKit/MobileVLCKit.h>
#import "UIView+DLCAnimation.h"
#import "UIDevice+DLCOrientation.h"
#import "Aspects.h"
#import "MSWeakTimer.h"
#import <AVKit/AVKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "BrowserVault-Swift.h"

NSString *const kDLCNotificationVideoDidPlay = @"kDLCNotificationVideoDidPlay";

static NSString *const kContentViewNibName = @"DLCBaseVideoContentView";
static NSTimeInterval const kDefaultHiddenDuration = 0.6;
static NSTimeInterval const kDefaultHiddenInterval = 5;
CGFloat heightLanscapeToolbarView = 45;
CGFloat LeadingAttributeTimerControlsView = 175;
CGFloat PaddingAttributeDefault = 5;

typedef NS_ENUM(NSUInteger, VLCAspectRatio) {
    VLCAspectRatioDefault = 0,
    VLCAspectRatioFillToScreen
};

@interface DLCBaseVideoView () <VLCMediaPlayerDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIView *videoDrawableView;
@property (weak, nonatomic) IBOutlet UILabel *remainingDurationLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentDurationlLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLanscapeLabel;
@property (weak, nonatomic) IBOutlet UILabel *remainingTimeLanscapeLabel;

@property (weak, nonatomic) IBOutlet UISlider *videoSlider;
@property (weak, nonatomic) IBOutlet UIView *topControlsView;
@property (weak, nonatomic) IBOutlet UIButton *minimizeButton;
@property (weak, nonatomic) IBOutlet UIView *playControlsView;
@property (weak, nonatomic) IBOutlet UIView *timerControlsView;


@property (weak, nonatomic) IBOutlet UIView *optionsLeftControl;
@property (weak, nonatomic) IBOutlet UIView *optionsRightControl;
@property (weak, nonatomic) IBOutlet UISlider *volumnSlider;
@property (weak, nonatomic) IBOutlet UISlider *mpSlider;
@property (nonatomic, strong) MPVolumeView* mpVolumn;
@property (weak, nonatomic) IBOutlet UIView *mpVolumnView;

@property (nonatomic, weak) UIViewController *superViewController;
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, strong) VLCMediaPlayer *mediaPlayer;
@property (nonatomic, weak) id<AspectToken> orientationAspectToken;
@property (nonatomic, weak) id<AspectToken> viewAppearAspectToken;
@property (nonatomic, weak) id<AspectToken> viewDisappearAspectToken;
@property (nonatomic, weak) id<DLCVideoActionDelegate> videoActionDelegate;
@property (nonatomic, assign) BOOL shouldResumeInActive;
@property (nonatomic, assign) BOOL videoPlayed;
@property (nonatomic, assign, getter=isToolBarHidden) BOOL toolBarHidden;
@property (nonatomic, strong) dispatch_queue_t playerControlQueue;
@property (nonatomic, strong) MSWeakTimer *toolbarHiddenTimer;
@property (nonatomic, assign) UIInterfaceOrientation originalOrientation;
@property (nonatomic, assign) BOOL observerForPauseInBackgroundAdded;
@property (nonatomic, assign) BOOL controlActive;
@property (nonatomic, assign) BOOL isVideoSliderMoving;
@property (nonatomic, assign) BOOL isVideoSliderComplete;
@property (nonatomic, assign) NSUInteger currentAspectRatio;
@property (nonatomic, strong) UITapGestureRecognizer* tapToSeekRecognizer;

@end

IB_DESIGNABLE
@implementation DLCBaseVideoView

+ (UIImage*)DLCImageName:(NSString*)name
{
    NSString* fileName = [NSString stringWithFormat:@"Player/%@", name];
    return [UIImage imageNamed: fileName];
}
#pragma mark - Public
- (void)playVideo {
    if (!self.isPlaying) {
        [self play];
        
        [self addObserverForPauseInBackground];
    }
}

- (void)pauseVideo {
    if (self.isPlaying) {
        [self pause];
        
        [self removeObserverForPauseInBackground];
    }
}

- (void)stopVideo {
    [self stop];
    
    [self removeObserverForPauseInBackground];
}

#pragma mark - Override
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self setup];
    }
    return self;
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (self.window) {
        if (!self.isVideoPlayed && self.shouldAutoPlay && self.mediaURL) {
            if ([self.videoActionDelegate respondsToSelector:@selector(dlc_videoWillPlay)]) {
                [self.videoActionDelegate dlc_videoWillPlay];
            }
        }
        [self resetToolBarHiddenTimer];
    }
}

- (void)dealloc {
    _videoActionDelegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:VLCMediaPlayerTimeChanged object:nil];
    [[AVAudioSession sharedInstance] removeObserver:self forKeyPath:@"outputVolume"];
    [_mediaPlayer.media clearStoredCookies];
    if (_mediaPlayer.media) {
        [_mediaPlayer pause];
        [_mediaPlayer stop];
    }
    _mediaPlayer = nil;
    
    [_toolbarHiddenTimer invalidate];
    self.shouldPauseInBackground = NO;
    _superViewController = nil;
    
    if (_fullScreen) {
        [_orientationAspectToken remove];
        [UIDevice dlc_setOrientation:_originalOrientation];
    }
    
    [_contentView removeFromSuperview];
    _contentView = nil;
}

#pragma mark - Init
- (void)setup {
    [self setupView];
    [self systemVolumn];
    self.volumnSlider.value = [AVAudioSession sharedInstance].outputVolume;
    
    self.videoActionDelegate = self;
    self.playerControlQueue = dispatch_queue_create("com.dklinzh.DLCMobilePlayer.controlQueue", DISPATCH_QUEUE_CONCURRENT);
    self.hiddenAnimation = -1;
    self.shouldPauseInBackground = YES;
    self.shouldControlAutoHidden = YES;
    self.currentAspectRatio = VLCAspectRatioDefault;
    
    [self initGesture];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timechangedLoadStateDidChange) name:VLCMediaPlayerTimeChanged object:nil];
    AVAudioSession* audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:YES error:nil];
    [audioSession addObserver:self
                   forKeyPath:@"outputVolume"
                      options:0
                      context:nil];
    if ([self isDeviceOrientationLandscape]) {
        [self updateUIFullScreenAnimated:NO];
        self.fullScreen = YES;
    }
}

- (void) systemVolumn
{
    self.mpVolumn = [[MPVolumeView alloc] initWithFrame:self.mpVolumnView.bounds];
    self.mpVolumn.showsRouteButton = [UIScreen screens].count > 1;
    self.mpVolumn.showsVolumeSlider = NO;
    [self.mpVolumnView addSubview:self.mpVolumn];
    for (UIView* view in self.mpVolumn.subviews) {
        if ([view isKindOfClass:[UISlider class]]) {
            self.mpSlider = (UISlider*) view;
        }
    }
}

- (void)setupView {
    NSBundle *bundle = [NSBundle bundleForClass:[DLCBaseVideoView class]];
    self.contentView = [bundle loadNibNamed:kContentViewNibName owner:self options:nil].firstObject;
    self.contentView.frame = self.bounds;
    self.contentView.clipsToBounds = YES;
    self.optionsLeftControl.layer.cornerRadius = 5.0;
    self.optionsRightControl.layer.cornerRadius = 5.0;
    self.toolbarView.layer.cornerRadius = 5.0;
    [self addSubview:self.contentView];
}

#pragma mark - DLCVideoActionDelegate
- (void)dlc_videoWillPlay {
    [self playVideo];
}

- (void)dlc_videoWillStop {
    [self stopVideo];
}

- (void)dlc_videoFullScreenChanged:(BOOL)isFullScreen {
    self.fullScreen = isFullScreen;
}

- (IBAction)videoSliderTouchUp:(id)sender {
    
}
- (IBAction)videoSliderTouchDown:(id)sender {
}
- (IBAction)videoSliderChange:(id)sender {
    VLCTime *newTime = [VLCTime timeWithInt:self.videoSlider.value];
    self.mediaPlayer.time = newTime;
    [self updateTimeLabelsWithTime:newTime];
}

- (void)dlc_playerControlActive:(BOOL)isActive {
    if ((self.controlActive = isActive)) {
        [self showToolBarView];
        [self resetToolBarHiddenTimer];
    } else {
        [self hideToolBarView];
    }
}
- (IBAction)volumnSliderChange:(id)sender {
    self.mpSlider.value = ((UISlider*) sender).value;
    [self.mpSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqual:@"outputVolume"]) {
        dispatch_async(dispatch_get_main_queue(), ^(void){
            float newVolume = [[AVAudioSession sharedInstance] outputVolume];
            self.volumnSlider.value = newVolume;
        });
    }
}


#pragma mark - Gesture
- (void)initGesture {
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] init];
    singleTap.delegate = self;
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.contentView addGestureRecognizer:singleTap];

    self.tapToSeekRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToSeekRecognized:)];
    [self.tapToSeekRecognizer setNumberOfTapsRequired:2];
    [self.contentView addGestureRecognizer:self.tapToSeekRecognizer];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        if ([self.videoActionDelegate respondsToSelector:@selector(dlc_playerControlActive:)]) {
            [self.videoActionDelegate dlc_playerControlActive:YES];
        }
    }
    return YES;
}

- (void)tapToSeekRecognized:(UITapGestureRecognizer *)tapRecognizer
{
    [self playerMinimizeAction:nil];
}

#pragma mark - Orientation

- (BOOL) isDeviceOrientationLandscape
{
    BOOL statusBarOrientationLanscape = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
    BOOL isValidInterfaceOrientation = UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation);
    return isValidInterfaceOrientation && statusBarOrientationLanscape;
}
- (void)orientationDidChange:(NSNotification*) notification {
    UIDevice* device = notification.object;
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown || orientation == UIDeviceOrientationUnknown) {
        return;
    }
    
    if (notification && UIDeviceOrientationIsLandscape(device.orientation) && !self.isFullScreen) {
        self.fullScreen = !self.isFullScreen;
    }
    
    if (notification && UIDeviceOrientationIsPortrait(device.orientation) && self.isFullScreen) {
        self.fullScreen = !self.isFullScreen;
        NSLog(@"test portrait");
    }
    
    if (self.isToolBarHidden) {
        self.toolBarHidden = NO;
        [self hideToolBarView];
    }
}

- (void)timechangedLoadStateDidChange
{
    [self updateTimeControls];
}

- (void)updateTimeControls
{
    if (self.mediaPlayer.media.length.value) {
        self.videoSlider.maximumValue = self.mediaPlayer.media.length.intValue;
        self.videoSlider.value = self.mediaPlayer.time.intValue;
    }
    
    [self updateTimeLabels];
}

- (void)updateTimeLabels
{
    [self updateTimeLabelsWithTime:self.mediaPlayer.time];
}

- (void) updateTimeLabelsWithTime:(VLCTime*) time
{
    self.currentTimeLanscapeLabel.text = @"";
    self.remainingTimeLanscapeLabel.text = @"";
    self.currentDurationlLabel.text = @"";
    self.remainingDurationLabel.text = @"";
    
    NSString* currentTime;
    NSString* remainingTime;
    if (time) {
        currentTime = time.stringValue;
        remainingTime = [VLCTime timeWithInt:(self.mediaPlayer.media.length.intValue - time.intValue)].stringValue;
        if (!self.showAdv && time.intValue >= 10 * 60 * 1000) {
            self.showAdv = YES;
        }
    } else {
        currentTime = @"00:00";
        remainingTime = @"00:00";
    }
    if ([self isFullScreen]) {
        self.currentTimeLanscapeLabel.text = currentTime;
        self.remainingTimeLanscapeLabel.text = remainingTime;
    } else {
        self.currentDurationlLabel.text = currentTime;
        self.remainingDurationLabel.text = remainingTime;
    }
}


#pragma mark - ToolBar
- (void)setOtherToolBarButtons:(NSArray<UIButton *> *)otherToolBarButtons {
    if (otherToolBarButtons) {
        _otherToolBarButtons = [otherToolBarButtons copy];
        NSUInteger count = _otherToolBarButtons.count;
        if (count > 0) {
            int margin = 18;
            NSDictionary *metrics = @{ @"margin": @(margin) };
            NSMutableString *Hvfl = [NSMutableString stringWithString:@"H:[btn_base]"];
            NSMutableDictionary *views = [NSMutableDictionary dictionaryWithDictionary:@{ @"btn_base": self.voiceBarButton }];
            for (int i = 0; i < count; i++) {
                UIButton *btn = _otherToolBarButtons[i];
                btn.translatesAutoresizingMaskIntoConstraints = NO;
                [self.toolbarView addSubview:btn];
                
                [Hvfl appendFormat:@"-margin-[btn_%d]", i];
                [views setValue:btn forKey:[NSString stringWithFormat:@"btn_%d", i]];
            }
            NSArray *Hconstraints = [NSLayoutConstraint constraintsWithVisualFormat:Hvfl options:NSLayoutFormatAlignAllCenterY metrics:metrics views:views];
            [self.toolbarView addConstraints:Hconstraints];
        }
    } else {
        if (_otherToolBarButtons) {
            for (UIButton *btn in _otherToolBarButtons) {
                [btn removeFromSuperview];
            }
            _otherToolBarButtons = nil;
        }
    }
}

- (CGFloat) topMarginControlsView
{
    CGFloat topMargin = 10;
    if (@available(iOS 11.0, *)) {
        topMargin += [UIApplication sharedApplication].keyWindow.safeAreaInsets.top;
        
    }
    return topMargin;
}

- (CGFloat) bottomMarginControlsView
{
    CGFloat bottomMargin = 10;
    if (@available(iOS 11.0, *)) {
        bottomMargin += [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
        
    }
    return bottomMargin;
}

- (void)hideToolBarView {
    
    if (!self.isToolBarHidden) {
        self.toolBarHidden = YES;
//        self.topControlsView.hidden = YES;
        switch (self.hiddenAnimation) {
            case DLCHiddenAnimationFade:
                [self.toolbarView dlc_fadeOutAnimationWithDuration:self.hiddenDuration];
                [self.topControlsView dlc_fadeOutAnimationWithDuration:self.hiddenDuration];
                break;
            case DLCHiddenAnimationSlide:
                [self.toolbarView dlc_slideOutFromBottomWithDuration:self.hiddenDuration];
                [self.topControlsView dlc_slideOutFromTopWithDuration:self.hiddenDuration];
                break;
            case DLCHiddenAnimationFadeSlide:
                [self.toolbarView dlc_fadeOutAnimationWithDuration:self.hiddenDuration/2.0];
                [self.toolbarView dlc_slideOutFromBottomWithDuration:self.hiddenDuration];
                
                [self.topControlsView dlc_fadeOutAnimationWithDuration:self.hiddenDuration/2.0];
                [self.topControlsView dlc_slideOutFromTopWithDuration:self.hiddenDuration];
                break;
            default:
                self.toolbarView.hidden = YES;
                self.topControlsView.hidden = YES;
                break;
        }
    }
}

- (void)showToolBarView {
    if (self.isToolBarHidden) {
        self.toolBarHidden = NO;
        
        CGFloat topMargin = self.topMarginControlsView;
        CGFloat bottomMargin = self.bottomMarginControlsView;
        
        switch (self.hiddenAnimation) {
            case DLCHiddenAnimationFade:
                [self.toolbarView dlc_fadeInAnimationWithDuration:self.hiddenDuration];
                [self.topControlsView dlc_fadeInAnimationWithDuration:self.hiddenDuration];
                break;
            case DLCHiddenAnimationSlide:
            {
                [self.toolbarView dlc_slideIntoBottomWithDuration:self.hiddenDuration padding:bottomMargin];
                [self.topControlsView dlc_slideIntoTopWithDuration:self.hiddenDuration padding:topMargin];
                break;
            }
            case DLCHiddenAnimationFadeSlide:
            {
                [self.toolbarView dlc_slideIntoBottomWithDuration:self.hiddenDuration/2.0 padding:bottomMargin];
                [self.toolbarView dlc_fadeInAnimationWithDuration:self.hiddenDuration];
                
                [self.topControlsView dlc_slideIntoTopWithDuration:self.hiddenDuration/2.0 padding:topMargin];
                [self.topControlsView dlc_fadeInAnimationWithDuration:self.hiddenDuration];
                break;
            }
            default:
                self.toolbarView.hidden = NO;
                self.topControlsView.hidden = NO;
                break;
        }
    }
}

- (void)resetToolBarHiddenTimer {
    if (self.shouldControlAutoHidden) {
        [self.toolbarHiddenTimer invalidate];
        self.toolbarHiddenTimer = [MSWeakTimer scheduledTimerWithTimeInterval:self.hiddenInterval target:self.videoActionDelegate selector:@selector(playerControlResign) userInfo:nil repeats:NO dispatchQueue:dispatch_get_main_queue()];
    }
}

- (void)playerControlResign {
    if ([self.videoActionDelegate respondsToSelector:@selector(dlc_playerControlActive:)]) {
        [self.videoActionDelegate dlc_playerControlActive:NO];
    }
}

- (NSTimeInterval)hiddenDuration {
    if (_hiddenDuration > 0) {
        return _hiddenDuration;
    }
    return kDefaultHiddenDuration;
}

- (NSTimeInterval)hiddenInterval {
    if (_hiddenInterval > 0) {
        return _hiddenInterval;
    }
    return kDefaultHiddenInterval;
}

- (DLCHiddenAnimation)hiddenAnimation {
    if (_hiddenAnimation >= 0) {
        return _hiddenAnimation;
    }
    return DLCHiddenAnimationFadeSlide;
}

#pragma mark - Background
- (UIViewController *)superViewController {
    if (_superViewController) {
        return _superViewController;
    }
    UIResponder *responder = self;
    while ((responder = [responder nextResponder])) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return _superViewController = (UIViewController *)responder;
        }
    }
    return nil;
}

- (void)addObserverForPauseInBackground {
    if (self.shouldPauseInBackground && !self.observerForPauseInBackgroundAdded) {
        self.observerForPauseInBackgroundAdded = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(resumeInActive)
                                                     name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(pauseInBackground)
                                                     name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        if (self.superViewController) {
            __weak __typeof(self)weakSelf = self;
            self.viewAppearAspectToken = [self.superViewController aspect_hookSelector:@selector(viewWillAppear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo) {
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                [strongSelf resumeInActive];
            } error:nil];
            self.viewDisappearAspectToken = [self.superViewController aspect_hookSelector:@selector(viewDidDisappear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo) {
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                [strongSelf pauseInBackground];
            } error:nil];
        }
    }
}

- (void)removeObserverForPauseInBackground {
    self.shouldResumeInActive = NO;
    if (self.shouldPauseInBackground && self.observerForPauseInBackgroundAdded) {
        self.observerForPauseInBackgroundAdded = NO;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        [self.viewAppearAspectToken remove];
        [self.viewDisappearAspectToken remove];
    }
}

- (void)pauseInBackground {
    if (self.isPlaying) {
        self.shouldResumeInActive = YES;
        [self pause];
    }
}

- (void)resumeInActive {
    if (self.shouldResumeInActive) {
        self.shouldResumeInActive = NO;
        [self play];
    }
}

- (void)setShouldPauseInBackground:(BOOL)shouldPauseInBackground {
    if (_shouldPauseInBackground != shouldPauseInBackground) {
        _shouldPauseInBackground = shouldPauseInBackground;
        if (!_shouldPauseInBackground && self.observerForPauseInBackgroundAdded) {
            self.observerForPauseInBackgroundAdded = NO;
            
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:UIApplicationWillEnterForegroundNotification object:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:UIApplicationDidEnterBackgroundNotification object:nil];
            
            [self.viewAppearAspectToken remove];
            [self.viewDisappearAspectToken remove];
        }
    }
}

#pragma mark - PlayControl
- (IBAction)videoPlayAction:(id)sender {
    if (self.playing) {
        [self pauseVideo];
    } else {
        if ([self.videoActionDelegate respondsToSelector:@selector(dlc_videoWillPlay)]) {
            [self.videoActionDelegate dlc_videoWillPlay];
        }
    }
}

- (void)play {
    if (!self.mediaURL) {
        NSLog(@"DLCMobilePlayer -warn: mediaURL is null.");
        return;
    }
    self.playing = YES;
    dispatch_async(self.playerControlQueue, ^{
        if (self.mediaPlayer.isPlaying) {
            [self.mediaPlayer pause];
        }
        [self.mediaPlayer play];
    });
}

- (void)pause {
    self.playing = NO;
    dispatch_barrier_async(self.playerControlQueue, ^{
        [self.mediaPlayer pause];
    });
}

- (void)stop {
    self.playing = NO;
    dispatch_barrier_async(self.playerControlQueue, ^{
        self.videoPlayed = NO;
        [self.mediaPlayer stop];
    });
}

- (void)videoPalyed {
    self.videoPlayButton.hidden = YES;
    if (self.isFullScreen) {
        [self.playBarButton setImage:[DLCBaseVideoView DLCImageName:@"btn_full_pause"] forState:UIControlStateNormal];
    } else {
        [self.playBarButton setImage:[DLCBaseVideoView DLCImageName:@"btn_toolbar_pause"] forState:UIControlStateNormal];
    }
}

- (void)videoStoped {
    self.buffering = NO;
    self.videoPlayButton.hidden = NO;
    if (self.isFullScreen) {
        [self.playBarButton setImage:[DLCBaseVideoView DLCImageName:@"btn_full_play"] forState:UIControlStateNormal];
    } else {
        [self.playBarButton setImage:[DLCBaseVideoView DLCImageName:@"btn_toolbar_play"] forState:UIControlStateNormal];
    }
}

- (void)setPlaying:(BOOL)playing {
    if (_playing != playing) {
        _playing = playing;
        if (_playing) {
            [self videoPalyed];
        } else {
            [self videoStoped];
        }
    }
}

#pragma mark - FullScreen
- (IBAction)videoFullScreenAction:(UIButton *)sender {
    if ([self.videoActionDelegate respondsToSelector:@selector(dlc_videoFullScreenChanged:)]) {
        [self.videoActionDelegate dlc_videoFullScreenChanged:!self.isFullScreen];
    }
}
- (IBAction)playerFastBackwardAction:(id)sender {
    [self.mediaPlayer jumpBackward:15];
}
- (IBAction)playerFastForwardAction:(id)sender {
    [self.mediaPlayer jumpForward:15];
}
- (IBAction)playerMinimizeAction:(id)sender {
    self.currentAspectRatio = self.currentAspectRatio == VLCAspectRatioDefault ? self.currentAspectRatio + 1 : VLCAspectRatioDefault;
    switch (self.currentAspectRatio) {
        case VLCAspectRatioDefault:
            [self updateMinimizeView];
            break;
        case VLCAspectRatioFillToScreen:
            [self updateMaximizeView];
            break;
    }
}

- (void) updateMinimizeView {
    self.mediaPlayer.videoAspectRatio = NULL;
    self.mediaPlayer.videoCropGeometry = NULL;
    [self.minimizeButton setImage:[DLCBaseVideoView DLCImageName:@"icon_player_maximize"] forState:UIControlStateNormal];
}

- (void) updateMaximizeView {
    self.mediaPlayer.videoCropGeometry = (char *)[[self screenAspectRatio] UTF8String];
    [self.minimizeButton setImage:[DLCBaseVideoView DLCImageName:@"icon_player_minimize"] forState:UIControlStateNormal];
}

- (NSString *)screenAspectRatio
{
    UIScreen *screen = [UIScreen screens].count > 1 ? [UIScreen screens][1] : [UIScreen mainScreen];
    return [NSString stringWithFormat:@"%d:%d", (int)screen.bounds.size.width, (int)screen.bounds.size.height];
}

- (void)enterFullScreen {
    Class delegateClass = [[UIApplication sharedApplication].delegate class];
    self.orientationAspectToken = [delegateClass aspect_hookSelector:@selector(application:supportedInterfaceOrientationsForWindow:) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> aspectInfo, UIApplication *application, UIWindow *window) {
        NSInvocation *invocation = aspectInfo.originalInvocation;
        [invocation invoke];
        UIInterfaceOrientationMask orientationMask = UIInterfaceOrientationMaskLandscape;
        [invocation setReturnValue:&orientationMask];
    } error:nil];
    if (![self isDeviceOrientationLandscape]) {
        [UIDevice dlc_setOrientation:UIInterfaceOrientationLandscapeRight];
    }
    [self updateUIFullScreenAnimated:YES];
    
}

- (void)exitFullScreen {
    [self.orientationAspectToken remove];
    [self updateUIExitFullScreen];
    
}

- (void) updateUIFullScreenAnimated:(BOOL) animated
{
    [self.fullScreenBarButton setImage:[DLCBaseVideoView DLCImageName:@"btn_full_exit"] forState:UIControlStateNormal];
    [self.videoPlayButton setImage:[DLCBaseVideoView DLCImageName:@"btn_full_play_def"] forState:UIControlStateNormal];
    [self.videoPlayButton setImage:[DLCBaseVideoView DLCImageName:@"btn_full_play_hl"] forState:UIControlStateHighlighted];
    CGFloat widthPlayControlsView = LeadingAttributeTimerControlsView + ([UIScreen screens].count > 1 ? 45 : 0);
    for (NSLayoutConstraint* constraint in self.toolbarView.constraints) {
        if (constraint.firstItem == self.toolbarView && constraint.firstAttribute == NSLayoutAttributeHeight) {
            constraint.constant = heightLanscapeToolbarView;
        } else if (constraint.secondItem == self.playControlsView && constraint.secondAttribute == NSLayoutAttributeTrailing) {
            constraint.priority = UILayoutPriorityDefaultLow;
        } else if (constraint.firstItem == self.timerControlsView && constraint.firstAttribute == NSLayoutAttributeLeading) {
            constraint.constant = widthPlayControlsView - 10;
        }
    }
    
    for (NSLayoutConstraint* constraint in self.playControlsView.constraints) {
        if (constraint.firstItem == self.playControlsView && constraint.firstAttribute == NSLayoutAttributeWidth) {
            constraint.constant = widthPlayControlsView;
            constraint.priority = UILayoutPriorityDefaultHigh;
        }
    }
    
    [self showVolumnView];
    
    NSUInteger duration = animated ? 0.5: 0;
    [UIView animateWithDuration:duration animations:^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [self.contentView removeFromSuperview];
        self.contentView.frame = window.bounds;
        [window addSubview:self.contentView];
    }];
    if (self.currentAspectRatio == VLCAspectRatioFillToScreen) {
        [self updateMaximizeView];
    }
}

- (void) updateUIExitFullScreen
{
    [self.fullScreenBarButton setImage:[DLCBaseVideoView DLCImageName:@"btn_toolbar_full_screen"] forState:UIControlStateNormal];
    [self.videoPlayButton setImage:[DLCBaseVideoView DLCImageName:@"btn_video_play_def"] forState:UIControlStateNormal];
    [self.videoPlayButton setImage:[DLCBaseVideoView DLCImageName:@"btn_video_play_hl"] forState:UIControlStateHighlighted];
    
    for (NSLayoutConstraint* constraint in self.toolbarView.constraints) {
        if (constraint.firstItem == self.toolbarView && constraint.firstAttribute == NSLayoutAttributeHeight) {
            constraint.constant = heightLanscapeToolbarView * 2;
        } else if (constraint.secondItem == self.playControlsView && constraint.secondAttribute == NSLayoutAttributeTrailing) {
            constraint.priority = UILayoutPriorityDefaultHigh;
        } else if (constraint.firstItem == self.timerControlsView && constraint.firstAttribute == NSLayoutAttributeLeading) {
            constraint.constant = PaddingAttributeDefault;
        }
    }
    
    for (NSLayoutConstraint* constraint in self.playControlsView.constraints) {
        if (constraint.firstItem == self.playControlsView && constraint.firstAttribute == NSLayoutAttributeWidth) {
            constraint.constant = LeadingAttributeTimerControlsView;
            constraint.priority = UILayoutPriorityDefaultLow;
        }
    }
    
    [self hideVolumnView];
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.contentView removeFromSuperview];
        self.contentView.frame = self.bounds;
        [self addSubview:self.contentView];
        [self sendSubviewToBack:self.contentView];
        
    } completion:nil];
    
    if (self.currentAspectRatio == VLCAspectRatioFillToScreen) {
        [self updateMaximizeView];
    }
}

- (void) showVolumnView
{
    self.volumnSlider.value = [AVAudioSession sharedInstance].outputVolume;
    if (!self.mediaPlayer.audio.muted) {
        for (NSLayoutConstraint* constraint in self.optionsRightControl.constraints) {
            if (constraint.firstItem == self.optionsRightControl && constraint.firstAttribute == NSLayoutAttributeWidth) {
                constraint.constant = 135;
            }
        }
        self.volumnSlider.hidden = NO;
    }
}

- (void) hideVolumnView
{
    for (NSLayoutConstraint* constraint in self.optionsRightControl.constraints) {
        if (constraint.firstItem == self.optionsRightControl && constraint.firstAttribute == NSLayoutAttributeWidth) {
            constraint.constant = 50;
        }
    }
    self.volumnSlider.hidden = YES;
}

- (void) updateUIWhenRotateDevice
{
    if (self.isPlaying) {
        [self videoPalyed];
    } else {
        [self videoStoped];
    }
    if (self.isMuted) {
        [self mutedOn];
    } else {
        [self mutedOff];
    }
}
- (void)setFullScreen:(BOOL)fullScreen {
    if (_fullScreen != fullScreen) {
        _fullScreen = fullScreen;
        if (_fullScreen) {
            [self enterFullScreen];
        } else {
            [self exitFullScreen];
        }
        [self updateUIWhenRotateDevice];
    }
}

#pragma mark - Audio
- (IBAction)videoVoiceAction:(UIButton *)sender {
    if ((self.muted = !self.isMuted)) {
        self.mediaPlayer.audio.muted = YES;
        if (self.isFullScreen) {
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                [self hideVolumnView];
            } completion:nil];
        }
    } else {
        self.mediaPlayer.audio.muted = NO;
        if (self.isFullScreen) {
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                [self showVolumnView];
            } completion:nil];
        }
    }
}

- (void)mutedOn {
    if (self.isFullScreen) {
        [self.voiceBarButton setImage:[DLCBaseVideoView DLCImageName:@"btn_full_voice_mute"] forState:UIControlStateNormal];
    } else {
        [self.voiceBarButton setImage:[DLCBaseVideoView DLCImageName:@"btn_toolbar_voice_mute"] forState:UIControlStateNormal];
    }
}

- (void)mutedOff {
    if (self.isFullScreen) {
        [self.voiceBarButton setImage:[DLCBaseVideoView DLCImageName:@"btn_full_voice"] forState:UIControlStateNormal];
    } else {
        [self.voiceBarButton setImage:[DLCBaseVideoView DLCImageName:@"btn_toolbar_voice"] forState:UIControlStateNormal];
    }
}

- (void)setMuted:(BOOL)muted {
    if (_muted != muted) {
        _muted = muted;
        if (_muted) {
            [self mutedOn];
        } else {
            [self mutedOff];
        }
    }
}

#pragma mark - Buffer
- (void)startBuffering {
    if (self.isPlaying) {
        self.videoBufferingView.hidden = NO;
        [self.videoBufferingView dlc_startRotateAnimationInDuration:2 repeatCout:HUGE_VALF];
    }
}

- (void)stopBuffering {
    [self.videoBufferingView dlc_stopRotateAnimation];
    self.videoBufferingView.hidden = YES;
}

- (void)setBuffering:(BOOL)buffering {
    if (_buffering != buffering) {
        _buffering = buffering;
        if (_buffering) {
            [self startBuffering];
        } else {
            [self stopBuffering];
        }
    }
}

#pragma mark - VLCMediaPlayer
- (VLCMediaPlayer *)mediaPlayer {
    if (_mediaPlayer) {
        return _mediaPlayer;
    }
    _mediaPlayer = [[VLCMediaPlayer alloc] init];
    //    _mediaPlayer = [[VLCMediaPlayer alloc] initWithOptions:@[@"-vvvv"]];
    _mediaPlayer.delegate = self;
    _mediaPlayer.drawable = self.videoDrawableView;
    return _mediaPlayer;
}

// Autoplay if necessary while mediaURL was changed.
- (void)setMediaURL:(NSString *)mediaURL {
    if (mediaURL) {
        if (![mediaURL isEqualToString:_mediaURL]) {
            NSURL* url = [NSURL URLWithString:mediaURL];
            if (url == nil) {
                url = [NSURL URLWithString:[mediaURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
            }
            if (url) {
                _mediaURL = [url.absoluteString copy];
            } else {
                _mediaURL = [mediaURL copy];
                if ([self.videoActionDelegate respondsToSelector:@selector(dlc_videoWillStop)]) {
                    [self.videoActionDelegate dlc_videoWillStop];
                }
                return;
            }
            dispatch_async(self.playerControlQueue, ^{
                self.mediaPlayer.media = [VLCMedia mediaWithURL:url];
                /*
                NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
                NSDictionary* values = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
                if (cookies != nil && values != nil) {
                    for (NSString* key in values.allKeys) {
                        [self.mediaPlayer.media storeCookie:[values[key] copy] forHost:[url.host copy] path:[url.path copy]];
                    }
                }
                */
            });
            
            if ([self.videoActionDelegate respondsToSelector:@selector(dlc_videoWillStop)]) {
                [self.videoActionDelegate dlc_videoWillStop];
            }
            
            if (self.shouldAutoPlay && self.window) {
                if ([self.videoActionDelegate respondsToSelector:@selector(dlc_videoWillPlay)]) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self.videoActionDelegate dlc_videoWillPlay];
                    });
                }
            }
        }
    } else {
        _mediaURL = [mediaURL copy];
        if ([self.videoActionDelegate respondsToSelector:@selector(dlc_videoWillStop)]) {
            [self.videoActionDelegate dlc_videoWillStop];
        }
    }
}


#pragma mark - VLCMediaPlayerDelegate

/**
 VLCMediaPlayerStateStopped,        //<0 Player has stopped
 VLCMediaPlayerStateOpening,        //<1 Stream is opening
 VLCMediaPlayerStateBuffering,      //<2 Stream is buffering
 VLCMediaPlayerStateEnded,          //<3 Stream has ended
 VLCMediaPlayerStateError,          //<4 Player has generated an error
 VLCMediaPlayerStatePlaying,        //<5 Stream is playing
 VLCMediaPlayerStatePaused          //<6 Stream is paused
 
 @param aNotification <#aNotification description#>
 */
- (void)mediaPlayerStateChanged:(NSNotification *)aNotification {
    NSLog(@"DLCMobilePlayer -mediaPlayerStateChanged: %ld", (long)self.mediaPlayer.state);
    NSLog(@"DLCMobilePlayer object: %@", aNotification.object);
    self.videoSlider.continuous = YES;
    switch (self.mediaPlayer.state) {
        case VLCMediaPlayerStateError:
        case VLCMediaPlayerStateStopped:
        case VLCMediaPlayerStateEnded:
            if ([self.videoActionDelegate respondsToSelector:@selector(dlc_videoWillStop)] && (self.isVideoPlayed || self.isBuffering)) {
                [self.videoActionDelegate dlc_videoWillStop];
            }
        case VLCMediaPlayerStatePaused:
            self.playing = NO;
            break;
        case VLCMediaPlayerStateBuffering:
            self.buffering = YES;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            [_mediaPlayer performSelector:@selector(setTextRendererFont:) withObject:@"TimesNewRomanPSMT"];
            [_mediaPlayer performSelector:@selector(setTextRendererFontSize:) withObject:@"12"];
            [_mediaPlayer performSelector:@selector(setTextRendererFontForceBold:) withObject:@NO];
#pragma clang diagnostic pop
            _mediaPlayer.currentVideoSubTitleIndex = -1;
            break;
        case VLCMediaPlayerStatePlaying:
            self.videoSlider.continuous = NO;
            break;
        default:
            break;
    }
}

- (void)mediaPlayerTimeChanged:(NSNotification *)aNotification {
    if (self.mediaPlayer.audio.isMuted != self.isMuted) {
        self.mediaPlayer.audio.muted = self.isMuted;
    }
    
    self.buffering = NO;
    if (!self.videoPlayed) {
        self.videoPlayed = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:kDLCNotificationVideoDidPlay object:self];
    }
}

- (void)mediaPlayerTitleChanged:(NSNotification *)aNotification {
    
}

- (void)mediaPlayerChapterChanged:(NSNotification *)aNotification {
    
}

- (void)mediaPlayerSnapshot:(NSNotification *)aNotification {
    
}

#pragma mark - IBInspectable
- (void)setHintText:(NSString *)hintText {
    _hintText = hintText;
    self.hintLabel.text = _hintText;
}

@end
