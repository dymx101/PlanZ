//
//  MMXMainMenuViewController.m
//  MathMatch
//
//  Created by Kyle O'Brien on 2014.1.16.
//  Copyright (c) 2014 Computer Lab. All rights reserved.
//

#import "MMXClassesViewController.h"
#import "MMXGameViewController.h"
#import "MMXMainMenuViewController.h"
#import "MMXNavigationController.h"
#import "MMXPracticeMenuAlphaViewController.h"
#import "MMXReportCardTableViewController.h"
#import "MMXSettingsViewController.h"
#import "FDAdmobManager.h"
#import "HMIAPHelper.h"
#import "UIViewController+PSContainment.h"

@interface MMXMainMenuViewController ()

@property (nonatomic, strong) MMXCardViewController *classesCardViewController;
@property (nonatomic, strong) MMXCardViewController *practiceCardViewController;
@property (nonatomic, strong) MMXCardViewController *howToPlayCardViewController;
@property (nonatomic, strong) MMXCardViewController *reportCardCardViewController;

@property (nonatomic, assign) BOOL startedAnimating;

@end

@implementation MMXMainMenuViewController


- (void)viewDidLoad
{
    [self observeNotification:NOTIFY_ID_REMOVE_ADS];
    [self observeNotification:NOTIFY_ID_RESTORE_ADS];
    [self observeNotification:FD_NOTIFICATION_AD_BANNER_READY];
    
    [super viewDidLoad];
    
    //self.bannerContainerView.backgroundColor = [UIColor redColor];
    
    self.classesCardViewController = [self initializeCardViewControllerInContainer:self.classesCardContainerView
                                                                         withStyle:MMXCardStyleBeach
                                                                         andNumber:1];
    
    self.practiceCardViewController = [self initializeCardViewControllerInContainer:self.practiceCardContainerView
                                                                          withStyle:MMXCardStyleCitrus
                                                                          andNumber:2];
    
    self.howToPlayCardViewController = [self initializeCardViewControllerInContainer:self.howToPlayCardContainerView
                                                                           withStyle:MMXCardStyleEmerald
                                                                           andNumber:3];
    
    self.reportCardCardViewController = [self initializeCardViewControllerInContainer:self.reportCardCardContainerView
                                                                            withStyle:MMXCardStyleVelvet
                                                                            andNumber:4];
    
    
    ///
    UIView *bannerView = [FDAdmobManager sharedManager].bannerView;
    bannerView.frame = self.bannerContainerView.bounds;
    bannerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.bannerContainerView addSubview:bannerView];
    
    /// request ads
    [[FDAdmobManager sharedManager] requestAds];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barTintColor = [UIColor mmx_blackColor];
}


#pragma mark - Player action

- (IBAction)playerTappedClassesButton:(id)sender
{
    [self flipForViewController:self.classesCardViewController];
}

- (IBAction)playerTappedPracticeButton:(id)sender
{
    [self flipForViewController:self.practiceCardViewController];
}

- (IBAction)playerTappedHowToPlayButton:(id)sender
{
    [self flipForViewController:self.howToPlayCardViewController];
}

- (IBAction)playerTappedReportCardButton:(id)sender
{
    [self flipForViewController:self.reportCardCardViewController];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MMXNavigationController *navigationController = (MMXNavigationController *)self.navigationController;
    
    if ([segue.identifier isEqualToString:@"MMXClassesSegue"])
    {
        MMXClassesViewController *classesViewController = (MMXClassesViewController *)segue.destinationViewController;
        classesViewController.managedObjectContext = navigationController.managedObjectContext;
    }
    else if ([segue.identifier isEqualToString:@"MMXPracticeSegue"])
    {
        MMXPracticeMenuAlphaViewController *practiceViewController = (MMXPracticeMenuAlphaViewController *)segue.destinationViewController;
        practiceViewController.managedObjectContext = navigationController.managedObjectContext;
    }
    else if ([segue.identifier isEqualToString:@"MMXHowToPlaySegue"])
    {
        MMXGameViewController *gameViewController = (MMXGameViewController *)segue.destinationViewController;
        gameViewController.managedObjectContext = navigationController.managedObjectContext;
        gameViewController.gameData = [NSEntityDescription insertNewObjectForEntityForName:@"MMXGameData"
                                                                     inManagedObjectContext:navigationController.managedObjectContext];
        gameViewController.gameData.gameType = MMXGameTypeHowToPlay;
        gameViewController.gameData.targetNumber = @10.0;
        gameViewController.gameData.numberOfCards = @12.0;
        gameViewController.gameData.arithmeticType = MMXArithmeticTypeAddition;
        gameViewController.gameData.startingPositionType = MMXStartingPositionTypeFaceUp;
        gameViewController.gameData.musicTrack = MMXAudioTrackGameplayEasy;
        gameViewController.gameData.cardStyle = MMXCardStyleThatch;
        gameViewController.manuallySpecifiedCardValues = @[@6, @4, @3, @7, @8, @2, @9, @1, @10, @0, @5, @5];
    }
    else if ([segue.identifier isEqualToString:@"MMXReportCardSegue"])
    {
        MMXReportCardTableViewController *reportCardTableViewController = (MMXReportCardTableViewController *)segue.destinationViewController;
        reportCardTableViewController.managedObjectContext = navigationController.managedObjectContext;
    }
    else if ([segue.identifier isEqualToString:@"MMXSettingsSegue"])
    {
        
        MMXNavigationController *modalNavigationController = (MMXNavigationController *)segue.destinationViewController;
        modalNavigationController.managedObjectContext = navigationController.managedObjectContext;
        
        [MMXAudioManager sharedManager].soundEffect = MMXAudioSoundEffectTapNeutral;
        [[MMXAudioManager sharedManager] playSoundEffect];
    }
}

#pragma mark - Helpers

- (MMXCardViewController *)initializeCardViewControllerInContainer:(UIView *)containerView
                                                         withStyle:(MMXCardStyle)cardStyle
                                                         andNumber:(NSInteger)number
{
    MMXCardViewController *cardViewController = [[MMXCardViewController alloc] initWithCardStyle:cardStyle];
    cardViewController.card = [[MMXCard alloc] initWithValue:number];
    cardViewController.delegate = self;
    cardViewController.shouldPlaySoundEffect = NO;
    [self installChildVC:cardViewController toContainerView:containerView];

    
    if (number == 1)
    {
        cardViewController.faceDownButton.accessibilityLabel = NSLocalizedString(@"Classes Card", nil);
    }
    else if (number == 2)
    {
        cardViewController.faceDownButton.accessibilityLabel = NSLocalizedString(@"Practice Card", nil);
    }
    else if (number == 3)
    {
        cardViewController.faceDownButton.accessibilityLabel = NSLocalizedString(@"How to Play Card", nil);
    }
    else if (number == 4)
    {
        cardViewController.faceDownButton.accessibilityLabel = NSLocalizedString(@"Report Card Card", nil);
    }
    
    return cardViewController;
}

- (void)flipForViewController:(MMXCardViewController *)cardViewController
{
    [MMXAudioManager sharedManager].soundEffect = MMXAudioSoundEffectTapForward;
    [[MMXAudioManager sharedManager] playSoundEffect];
    
    self.startedAnimating = YES;
    
    [self enableButtons:NO];
    
    // Don't want the player to trigger the segue twice.
    if (!cardViewController.card.isFaceUp)
    {
        [cardViewController flipCardFaceUp];
    }
}

- (void)enableButtons:(BOOL)enable
{
    self.classesButton.enabled = enable;
    self.practiceButton.enabled = enable;
    self.howToPlayButton.enabled = enable;
    self.reportCardButton.enabled = enable;
    
    self.classesCardViewController.view.userInteractionEnabled = enable;
    self.practiceCardViewController.view.userInteractionEnabled = enable;
    self.howToPlayCardViewController.view.userInteractionEnabled = enable;
    self.reportCardCardViewController.view.userInteractionEnabled = enable;
}

#pragma mark - MMXCardViewControllerDelegate

- (BOOL)requestedFlipFor:(MMXCardViewController *)cardViewController
{
    [self enableButtons:NO];
    
    if (!self.startedAnimating)
    {
        self.startedAnimating = YES;
        
        [MMXAudioManager sharedManager].soundEffect = MMXAudioSoundEffectTapForward;
        [[MMXAudioManager sharedManager] playSoundEffect];
    }
    
    return YES;
}

- (void)finishedFlippingFaceDownFor:(MMXCardViewController *)cardViewController
{
    
}

- (void)finishedFlippingFaceUpFor:(MMXCardViewController *)cardViewController
{
    NSString *segue = nil;
    if (cardViewController == self.classesCardViewController)
    {
        segue = @"MMXClassesSegue";
    }
    else if (cardViewController == self.practiceCardViewController)
    {
        segue = @"MMXPracticeSegue";
    }
    else if (cardViewController == self.howToPlayCardViewController)
    {
        segue = @"MMXHowToPlaySegue";
    }
    else if (cardViewController == self.reportCardCardViewController)
    {
        segue = @"MMXReportCardSegue";
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.14 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
    {
        if (segue)
        {
            [self performSegueWithIdentifier:segue sender:nil];
        }
        
        [cardViewController flipCardFaceDown];
        
        [self enableButtons:YES];
        
        self.startedAnimating = NO;
    });
}

-(void)handleNotification:(NSNotification *)notification {
    if ([notification.name isEqualToString:FD_NOTIFICATION_AD_BANNER_READY]) {
        
        if (![SharedIAP hasRemovedAds]) {
            [[FDAdmobManager sharedManager] showBanner];
        }
        
        
    } else if ([notification.name isEqualToString:NOTIFY_ID_REMOVE_ADS]) {
        
        [[FDAdmobManager sharedManager].bannerView removeFromSuperview];
        
    } else if ([notification.name isEqualToString:NOTIFY_ID_RESTORE_ADS]) {
        
    }
}

@end
