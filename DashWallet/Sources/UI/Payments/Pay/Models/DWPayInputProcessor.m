//
//  Created by Andrew Podkovyrin
//  Copyright © 2019 Dash Core Group. All rights reserved.
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

#import "DWPayInputProcessor.h"

#import "DWEnvironment.h"
#import <DashSync/DashSync.h>

NS_ASSUME_NONNULL_BEGIN

@interface DWPaymentInput ()

@property (nullable, nonatomic, strong) DSPaymentRequest *request;
@property (nullable, nonatomic, strong) DSPaymentProtocolRequest *protocolRequest;

@end

@implementation DWPaymentInput

- (instancetype)initWithSource:(DWPaymentInputSource)source {
    self = [super init];
    if (self) {
        _source = source;
    }
    return self;
}

- (nullable NSString *)userDetails {
    if (self.request) {
        return self.request.string;
    }
    else if (self.protocolRequest) {
        return (self.protocolRequest.details.memo ?: self.protocolRequest.details.paymentURL) ?: @"<?>";
    }

    return nil;
}

@end

#pragma mark - Processor

@implementation DWPayInputProcessor

- (void)payFirstFromArray:(NSArray<NSString *> *)array
                   source:(DWPaymentInputSource)source
               completion:(void (^)(DWPaymentInput *paymentInput))completion {
    NSUInteger i = 0;
    DSChain *chain = [DWEnvironment sharedInstance].currentChain;
    DSAccount *account = [DWEnvironment sharedInstance].currentAccount;
    for (NSString *str in array) {
        DSPaymentRequest *request = [DSPaymentRequest requestWithString:str onChain:chain];
        NSData *data = str.hexToData.reverse;

        i++;

        // if the clipboard contains a known txHash, we know it's not a hex encoded private key
        if (data.length == sizeof(UInt256) && [account transactionForHash:*(UInt256 *)data.bytes]) {
            continue;
        }

        if ([request.paymentAddress isValidDashAddressOnChain:chain] || [str isValidDashPrivateKeyOnChain:chain] || [str isValidDashBIP38Key] ||
            (request.r.length > 0 && ([request.scheme isEqual:@"dash:"]))) {
            if (completion) {
                DWPaymentInput *paymentInput = [[DWPaymentInput alloc] initWithSource:source];
                paymentInput.request = request;
                completion(paymentInput);
            }

            return;
        }
        else if (request.r.length > 0) { // may be BIP73 url: https://github.com/bitcoin/bips/blob/master/bip-0073.mediawiki
            [DSPaymentRequest
                     fetch:request.r
                    scheme:request.scheme
                   onChain:chain
                   timeout:5.0
                completion:^(DSPaymentProtocolRequest *protocolRequest, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (error) { // don't try any more BIP73 urls
                            NSIndexSet *filteredIndexes =
                                [array indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                                    return (idx >= i && ([obj hasPrefix:@"dash:"] || ![NSURL URLWithString:obj]));
                                }];
                            NSArray<NSString *> *filteredArray = [array objectsAtIndexes:filteredIndexes];
                            [self payFirstFromArray:filteredArray source:source completion:completion];
                        }
                        else {
                            if (completion) {
                                DWPaymentInput *paymentInput = [[DWPaymentInput alloc] initWithSource:source];
                                paymentInput.protocolRequest = protocolRequest;
                                completion(paymentInput);
                            }
                        }
                    });
                }];

            return;
        }
    }

    if (completion) {
        DWPaymentInput *paymentInput = [[DWPaymentInput alloc] initWithSource:source];
        completion(paymentInput);
    }
}

@end

NS_ASSUME_NONNULL_END
