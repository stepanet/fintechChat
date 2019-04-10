//
//  ThemesViewController.h
//  fintechChat
//
//  Created by Jack Sp@rroW on 04/03/2019.
//  Copyright © 2019 Jack Sp@rroW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThemesViewControllerDelegate.h"
#import "Themes.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThemesViewController : UIViewController

@property (nonatomic, weak) id <ThemesViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
