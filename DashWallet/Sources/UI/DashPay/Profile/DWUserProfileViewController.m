//
//  Created by Andrew Podkovyrin
//  Copyright © 2020 Dash Core Group. All rights reserved.
//
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

#import "DWUserProfileViewController.h"

#import "DWActivityCollectionViewCell.h"
#import "DWStretchyHeaderCollectionViewFlowLayout.h"
#import "DWUIKit.h"
#import "DWUserProfileContactActionsCell.h"
#import "DWUserProfileHeaderView.h"
#import "DWUserProfileModel.h"
#import "DWUserProfileNavigationTitleView.h"

NS_ASSUME_NONNULL_BEGIN

@interface DWUserProfileViewController () <UICollectionViewDataSource,
                                           UICollectionViewDelegate,
                                           UICollectionViewDelegateFlowLayout,
                                           DWUserProfileModelDelegate,
                                           DWUserProfileHeaderViewDelegate,
                                           DWUserProfileContactActionsCellDelegate>

@property (readonly, nonatomic, strong) DWUserProfileModel *model;

@property (null_resettable, nonatomic, strong) UICollectionView *collectionView;
@property (nullable, nonatomic, weak) DWUserProfileHeaderView *headerView;

@end

NS_ASSUME_NONNULL_END

@implementation DWUserProfileViewController

- (instancetype)initWithItem:(id<DWDPBasicItem>)item {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _model = [[DWUserProfileModel alloc] initWithItem:item];
        _model.delegate = self;
        [_model update];

        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (DWNavigationBarAppearance)navigationBarAppearance {
    return DWNavigationBarAppearanceWhite;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor dw_secondaryBackgroundColor];

    DWUserProfileNavigationTitleView *titleView = [[DWUserProfileNavigationTitleView alloc] initWithFrame:CGRectZero];
    [titleView updateWithUsername:self.model.username];
    CGSize titleSize = [titleView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    titleView.frame = CGRectMake(0, 0, titleSize.width, titleSize.height);
    self.navigationItem.titleView = titleView;

    [self.view addSubview:self.collectionView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.collectionView flashScrollIndicators];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        BOOL shouldDisplayActions = self.model.state == DWUserProfileModelState_Done &&
                                    self.model.friendshipStatus == DSBlockchainIdentityFriendshipStatus_Incoming;
        return shouldDisplayActions ? 1 : 0;
    }
    else {
        return 20;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 0) {
        return nil;
    }

    DWUserProfileHeaderView *headerView = (DWUserProfileHeaderView *)[collectionView
        dequeueReusableSupplementaryViewOfKind:kind
                           withReuseIdentifier:DWUserProfileHeaderView.dw_reuseIdentifier
                                  forIndexPath:indexPath];
    headerView.model = self.model;
    headerView.delegate = self;
    self.headerView = headerView;
    return headerView;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        DWUserProfileContactActionsCell *cell = [collectionView
            dequeueReusableCellWithReuseIdentifier:DWUserProfileContactActionsCell.dw_reuseIdentifier
                                      forIndexPath:indexPath];
        cell.username = self.model.username;
        cell.delegate = self;
        [cell configureForIncomingStatus];
        return cell;
    }
    else {
        DWActivityCollectionViewCell *cell = [collectionView
            dequeueReusableCellWithReuseIdentifier:DWActivityCollectionViewCell.dw_reuseIdentifier
                                      forIndexPath:indexPath];
        cell.text = [NSString stringWithFormat:@"Placeholder %@ - %@", @(indexPath.section), @(indexPath.item)];
        return cell;
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section != 0) {
        return CGSizeZero;
    }

    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    UIView *headerView = [self collectionView:collectionView
            viewForSupplementaryElementOfKind:UICollectionElementKindSectionHeader
                                  atIndexPath:indexPath];
    const CGSize size = [headerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return CGSizeMake(collectionView.bounds.size.width, 120);
    }
    else {
        return CGSizeMake(collectionView.bounds.size.width, 50);
    }
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    const CGFloat contentOffsetY = scrollView.contentOffset.y;
    const CGFloat headerHeight = CGRectGetHeight(self.headerView.bounds);
    const float percent = headerHeight > 0.0 ? contentOffsetY / headerHeight : 0.0;

    [self.headerView setScrollingPercent:percent];

    DWUserProfileNavigationTitleView *titleView = (DWUserProfileNavigationTitleView *)self.navigationItem.titleView;
    NSAssert([titleView isKindOfClass:DWUserProfileNavigationTitleView.class], @"Invalid titleView");
    [titleView setScrollingPercent:percent];
}

#pragma mark - DWUserProfileModelDelegate

- (void)userProfileModelDidUpdateState:(DWUserProfileModel *)model {
    [self.collectionView reloadData];
}

#pragma mark - DWUserProfileHeaderViewDelegate

- (void)userProfileHeaderView:(DWUserProfileHeaderView *)view actionButtonAction:(UIButton *)sender {
    if (self.model.friendshipStatus == DSBlockchainIdentityFriendshipStatus_None) {
        [self.model sendContactRequest];
    }
}

#pragma mark - DWUserProfileContactActionsCellDelegate

- (void)userProfileContactActionsCell:(DWUserProfileContactActionsCell *)cell mainButtonAction:(UIButton *)sender {
    if (self.model.friendshipStatus == DSBlockchainIdentityFriendshipStatus_Incoming) {
        [self.model acceptContactRequest];
    }
}

- (void)userProfileContactActionsCell:(DWUserProfileContactActionsCell *)cell secondaryButtonAction:(UIButton *)sender {
}

#pragma mark - Private

- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        DWStretchyHeaderCollectionViewFlowLayout *layout = [[DWStretchyHeaderCollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;

        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:UIScreen.mainScreen.bounds
                                                              collectionViewLayout:layout];
        collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        collectionView.dataSource = self;
        collectionView.delegate = self;
        collectionView.backgroundColor = [UIColor dw_secondaryBackgroundColor];
        collectionView.alwaysBounceVertical = YES;

        [collectionView registerClass:DWActivityCollectionViewCell.class
            forCellWithReuseIdentifier:DWActivityCollectionViewCell.dw_reuseIdentifier];

        [collectionView registerClass:DWUserProfileContactActionsCell.class
            forCellWithReuseIdentifier:DWUserProfileContactActionsCell.dw_reuseIdentifier];

        [collectionView registerClass:DWUserProfileHeaderView.class
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:DWUserProfileHeaderView.dw_reuseIdentifier];

        _collectionView = collectionView;
    }
    return _collectionView;
}
@end