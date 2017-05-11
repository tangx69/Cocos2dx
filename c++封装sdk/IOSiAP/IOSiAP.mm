#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#import "IOSiAP.h"

/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface iAPProductsRequestDelegate : NSObject<SKProductsRequestDelegate>
@property (nonatomic, assign) IOSiAP *iosiap;
@end

@implementation iAPProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request
     didReceiveResponse:(SKProductsResponse *)response
{
    // release old
    if (_iosiap->skProducts) {
        [(NSArray *)(_iosiap->skProducts) release];
    }
    // record new product
    _iosiap->skProducts = [response.products retain];
    
    for (int index = 0; index < [response.products count]; index++) {
        SKProduct *skProduct = [response.products objectAtIndex:index];
        
        // check is valid
        bool isValid = true;
        for (NSString *invalidIdentifier in response.invalidProductIdentifiers) {
            NSLog(@"invalidIdentifier:%@", invalidIdentifier);
            if ([skProduct.productIdentifier isEqualToString:invalidIdentifier]) {
                isValid = false;
                break;
            }
        }
        
        IOSProduct *iosProduct = new IOSProduct;
        iosProduct->productIdentifier = std::string([skProduct.productIdentifier UTF8String]);
        //iosProduct->localizedTitle = std::string([skProduct.localizedTitle UTF8String]);
        //iosProduct->localizedDescription = std::string([skProduct.localizedDescription UTF8String]);
        
        // locale price to string
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [formatter setLocale:skProduct.priceLocale];
        NSString *priceStr = [formatter stringFromNumber:skProduct.price];
        [formatter release];
        iosProduct->localizedPrice = std::string([priceStr UTF8String]);
        
        iosProduct->index = index;
        iosProduct->isValid = isValid;
        _iosiap->iOSProducts.push_back(iosProduct);
    }
}

- (void)requestDidFinish:(SKRequest *)request
{
    _iosiap->delegate->onRequestProductsFinish();
    [request.delegate release];
    [request release];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
    _iosiap->delegate->onRequestProductsError([error code]);
}

@end

/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface iAPTransactionObserver : NSObject<SKPaymentTransactionObserver>
@property (nonatomic, assign) IOSiAP *iosiap;
@end

@implementation iAPTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions) {
        std::string identifier([transaction.payment.productIdentifier UTF8String]);
        IOSiAPPaymentEvent event;
        
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:{
                event = IOSIAP_PAYMENT_PURCHASING;
                return;
            }

            case SKPaymentTransactionStatePurchased:
            {
                BOOL result = [self verifyReceipt: transaction];
                if(result){
                    event = IOSIAP_PAYMENT_PURCHAED;
                }else {
                    event = IOSIAP_PAYMENT_PURCHASING;
                }
                break;
            }

            case SKPaymentTransactionStateFailed:{
                event = IOSIAP_PAYMENT_FAILED;
                NSLog(@"==ios payment error:%@", transaction.error);
                break;
            }

            case SKPaymentTransactionStateRestored:{
                // NOTE: consumble payment is NOT restorable
                event = IOSIAP_PAYMENT_RESTORED;
                break;
            }
            case SKPaymentTransactionStateDeferred:{
                event = IOSIAP_PAYMENT_PURCHASING;
                return;
            }
        }
        
        _iosiap->delegate->onPaymentEvent(identifier, event, transaction.payment.quantity);
        if (event != IOSIAP_PAYMENT_PURCHASING) {
            [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
        }
    }
}


- (BOOL)verifyReceipt:(SKPaymentTransaction *)transaction {
    NSString *jsonObjectString = [self encode:(uint8_t *)transaction.transactionReceipt.bytes length:transaction.transactionReceipt.length];
    
    NSString *extString= [NSString stringWithCString:_iosiap->extString.c_str() encoding:[NSString defaultCStringEncoding]];
    
    NSString *completeString = [NSString stringWithFormat:@"receipt=%@&ext=%@", jsonObjectString, extString];

    NSData *postData = [completeString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    NSURL *urlForValidation = [NSURL URLWithString:completeString];
    NSMutableURLRequest *validationRequest = [[[NSMutableURLRequest alloc] init] autorelease];
    
//    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    [validationRequest setURL:[NSURL URLWithString:@"http://gjlogin.hzfunyou.com:8188/iap"]];
    [validationRequest setHTTPMethod:@"POST"];
    [validationRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [validationRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [validationRequest setHTTPBody:postData];
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:validationRequest returningResponse:nil error:nil];
//    [validationRequest release];
    if (responseData == nil) {
        
        NSMutableURLRequest *validationRequestIP = [[[NSMutableURLRequest alloc] init] autorelease];
        
        //    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
        [validationRequestIP setURL:[NSURL URLWithString:@"http://115.159.66.225:8188/iap"]];
        [validationRequestIP setHTTPMethod:@"POST"];
        [validationRequestIP setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [validationRequestIP setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [validationRequestIP setHTTPBody:postData];
        responseData = [NSURLConnection sendSynchronousRequest:validationRequestIP returningResponse:nil error:nil];
    }
    if(responseData == nil){
        return false;
    }
    
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
    NSInteger response = [responseString integerValue];
    [responseString release];
    return (response == 0);
}

- (NSString *)encode:(const uint8_t *)input length:(NSInteger)length {
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData *data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t *output = (uint8_t *)data.mutableBytes;
    
    for (NSInteger i = 0; i < length; i += 3) {
        NSInteger value = 0;
        for (NSInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger index = (i / 3) * 4;
        output[index + 0] =                    table[(value >> 18) & 0x3F];
        output[index + 1] =                    table[(value >> 12) & 0x3F];
        output[index + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[index + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
}


- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions) {
        std::string identifier([transaction.payment.productIdentifier UTF8String]);
        _iosiap->delegate->onPaymentEvent(identifier, IOSIAP_PAYMENT_REMOVED, transaction.payment.quantity);
    }
}

// Sent when an error is encountered while adding transactions from the user's purchase history back to the queue.
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    
    _iosiap->delegate->onRestoreFinished(false);
    //NSLog(@"restore completed transactions failded.");
}

// Sent when all transactions from the user's purchase history have successfully been added back to the queue.
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    _iosiap->delegate->onRestoreFinished(true);
    //NSLog(@"restore completed transactions finished.");
}

@end

/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////

IOSiAP::IOSiAP():
skProducts(nullptr),
delegate(nullptr)
{
    skTransactionObserver = [[iAPTransactionObserver alloc] init];
    ((iAPTransactionObserver *)skTransactionObserver).iosiap = this;
    [[SKPaymentQueue defaultQueue] addTransactionObserver:(iAPTransactionObserver *)skTransactionObserver];
}

IOSiAP::~IOSiAP()
{
    if (skProducts) {
        [(NSArray *)(skProducts) release];
    }
    
    std::vector <IOSProduct *>::iterator iterator;
    for (iterator = iOSProducts.begin(); iterator != iOSProducts.end(); iterator++) {
        IOSProduct *iosProduct = *iterator;
        delete iosProduct;
    }
    
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:(iAPTransactionObserver *)skTransactionObserver];
    [(iAPTransactionObserver *)skTransactionObserver release];
}

IOSProduct *IOSiAP::iOSProductByIdentifier(std::string &identifier)
{
    std::vector <IOSProduct *>::iterator iterator;
    for (iterator = iOSProducts.begin(); iterator != iOSProducts.end(); iterator++) {
        IOSProduct *iosProduct = *iterator;
        if (iosProduct->productIdentifier == identifier) {
            return iosProduct;
        }
    }

    return nullptr;
}

void IOSiAP::requestProducts(std::vector <std::string> &productIdentifiers)
{
    NSMutableSet *set = [NSMutableSet setWithCapacity:productIdentifiers.size()];
    std::vector <std::string>::iterator iterator;
    for (iterator = productIdentifiers.begin(); iterator != productIdentifiers.end(); iterator++) {
        [set addObject:[NSString stringWithUTF8String:(*iterator).c_str()]];
    }
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
    iAPProductsRequestDelegate *delegate = [[iAPProductsRequestDelegate alloc] init];
    delegate.iosiap = this;
    productsRequest.delegate = delegate;
    [productsRequest start];
}

void IOSiAP::paymentWithProduct(IOSProduct *iosProduct, std::string ext, int quantity)
{
    extString = ext;
    SKProduct *skProduct = [(NSArray *)(skProducts) objectAtIndex:iosProduct->index];
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:skProduct];
    payment.quantity = quantity;
    
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

void IOSiAP::restorePayment()
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
