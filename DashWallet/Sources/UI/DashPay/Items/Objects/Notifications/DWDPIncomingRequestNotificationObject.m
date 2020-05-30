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

#import "DWDPIncomingRequestNotificationObject.h"

#import <DashSync/DashSync.h>

NS_ASSUME_NONNULL_BEGIN

@interface DWDPIncomingRequestNotificationObject ()

@property (readonly, nonatomic, strong) NSDateFormatter *dateFormatter;
@property (readonly, nonatomic, strong) NSDate *date;

@end

NS_ASSUME_NONNULL_END

@implementation DWDPIncomingRequestNotificationObject

@synthesize subtitle = _subtitle;

- (instancetype)initWithFriendRequestEntity:(DSFriendRequestEntity *)friendRequestEntity
                              dateFormatter:(NSDateFormatter *)dateFormatter {
    self = [super initWithFriendRequestEntity:friendRequestEntity];
    if (self) {
        _dateFormatter = dateFormatter;
        // TODO: get from entity
        _date = [NSDate date];
    }
    return self;
}

- (NSString *)subtitle {
    if (_subtitle == nil) {
        _subtitle = [self.dateFormatter stringFromDate:self.date];
    }
    return _subtitle;
}

@end
