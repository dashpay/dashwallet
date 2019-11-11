//
//  DWSignPayloadViewController.h
//  DashWallet
//
//  Created by Sam Westrich on 3/8/19.
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://opensource.org/licenses/MIT
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "DWBaseActionButtonViewController.h"
#import "DWSignPayloadModel.h"
#import <KVO-MVVM/KVOUIViewController.h>
#import <UIKit/UIKit.h>

@class DSProviderRegistrationTransaction;

NS_ASSUME_NONNULL_BEGIN

@protocol DWSignPayloadDelegate

- (void)viewController:(UIViewController *)controller didReturnSignature:(NSData *)signature;

@end

@interface DWSignPayloadViewController : DWBaseActionButtonViewController

@property (nonatomic, readonly) DWSignPayloadModel *model;

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

- (instancetype)initWithModel:(DWSignPayloadModel *)model NS_DESIGNATED_INITIALIZER;

@property (nonatomic, weak) id<DWSignPayloadDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
