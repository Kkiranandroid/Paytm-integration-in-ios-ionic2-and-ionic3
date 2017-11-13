#import "PayTMCordova.h"
#import <Cordova/CDV.h>

@implementation PayTMCordova{
    NSString* callbackId;
    PGTransactionViewController* txnController;
}

- (void)startPayment:(CDVInvokedUrlCommand *)command {
    
    callbackId = command.callbackId;
//    orderId, customerId, email, phone, amount,
    NSString *orderId  = [command.arguments objectAtIndex:0];
    NSString *customerId = [command.arguments objectAtIndex:1];
    NSString *email = [command.arguments objectAtIndex:2];
    NSString *checksum = [command.arguments objectAtIndex:3];
    NSString *amount = [command.arguments objectAtIndex:4];
    
    NSBundle* mainBundle;
    mainBundle = [NSBundle mainBundle];
    
//     NSString* paytm_generate_url = [mainBundle objectForInfoDictionaryKey:@"PayTMGenerateChecksumURL"];
//     NSString* paytm_validate_url = [mainBundle objectForInfoDictionaryKey:@"PayTMVerifyChecksumURL"];
//     NSString* paytm_merchant_id = [mainBundle objectForInfoDictionaryKey:@"PayTMMerchantID"];
//     NSString* paytm_ind_type_id = [mainBundle objectForInfoDictionaryKey:@"PayTMIndustryTypeID"];
//     NSString* paytm_website = [mainBundle objectForInfoDictionaryKey:@"PayTMWebsite"];
    

//Step 1: Create a default merchant config object
    PGMerchantConfiguration *mc = [PGMerchantConfiguration defaultConfiguration];
    
    //Step 2: Create the order with whatever params you want to add. But make sure that you include the merchant mandatory params
    NSMutableDictionary *orderDict = [NSMutableDictionary new];

    /*orderDict[@"REQUEST_TYPE"] = @"DEFAULT";*/
    orderDict[@"MID"] = @"**************";
    orderDict[@"ORDER_ID"] = orderId;
    orderDict[@"CUST_ID"] = customerId;
    orderDict[@"INDUSTRY_TYPE_ID"] = @"Retail";
    orderDict[@"CHANNEL_ID"] = @"WAP";
    orderDict[@"TXN_AMOUNT"] = @"10.0";
    orderDict[@"WEBSITE"] = @"Microwap";
    orderDict[@"CALLBACK_URL"] = @"https://pguat.paytm.com/paytmchecksum/paytmCallback.jsp";
    orderDict[@"CHECKSUMHASH"] = checksum;
  orderDict[@"EMAIL"] = email;
  orderDict[@"MOBILE_NO"] = @"999999999999";
    PGOrder *order = [PGOrder orderWithParams:orderDict];
  {
         PGTransactionViewController *txnController = [[PGTransactionViewController alloc] initTransactionForOrder:order];
             txnController.serverType = eServerTypeStaging;
               txnController.merchant = [PGMerchantConfiguration defaultConfiguration];
             txnController.delegate = self;
             txnController.loggingEnabled = YES;
            UIViewController *rootVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
   [rootVC.navigationController pushViewController:txnController animated:true];
   [rootVC presentViewController:txnController animated:YES completion:nil];
             
     };
}

#pragma mark PGTransactionViewController delegate

-(void)didFinishedResponse:(PGTransactionViewController *)controller response:(NSString *)responseString {
    DEBUGLOG(@"ViewController::didFinishedResponse:response = %@", responseString);

 

 NSString *url=@"https://test.com/paytm_demo/verifyChecksum.php";
    
    NSURL *url1 = [NSURL URLWithString:url];
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url1];
    
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:15.0];
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSData *requestBody = [responseString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    [request setHTTPBody:requestBody];
    
    NSURLResponse *response;
   
    
    NSError *error;
    NSData *newData = [self sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *responseString1 = [[NSString alloc] initWithData:newData encoding:NSUTF8StringEncoding];

    NSData* data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *myError = nil;
    
    NSMutableDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&myError];
    
  
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:res];
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    [txnController dismissViewControllerAnimated:YES completion:nil];
}
- (NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error
{
    NSError __block *err = NULL;
    NSData __block *data;
    BOOL __block reqProcessed = false;
    NSURLResponse __block *resp;
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable _data, NSURLResponse * _Nullable _response, NSError * _Nullable _error)
      {
          resp = _response;
          err = _error;
          data = _data;
          reqProcessed = true;
      }] resume];
    
    while (!reqProcessed)
    {
        [NSThread sleepForTimeInterval:0];
    }
    *response = resp;
    *error = err;
    return data;
}

- (void)didFinishCASTransaction:(PGTransactionViewController *)controller response:(NSDictionary *)response
{
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:response];
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    [txnController dismissViewControllerAnimated:YES completion:nil];
}
+(NSString*)generateOrderIDWithPrefix:(NSString *)prefix
{
    srand ( (unsigned)time(NULL) );
    int randomNo = rand(); //just randomizing the number
    NSString *orderID = [NSString stringWithFormat:@"%@%d", prefix, randomNo];
    return orderID;
}



//Called when a transaction has completed. response dictionary will be having details about Transaction.
- (void)didSucceedTransaction:(PGTransactionViewController *)controller
                     response:(NSDictionary *)response{
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:response];
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    [txnController dismissViewControllerAnimated:YES completion:nil];
}

//Called when a transaction is failed with any reason. response dictionary will be having details about failed Transaction.
- (void)didFailTransaction:(PGTransactionViewController *)controller
                     error:(NSError *)error
                  response:(NSDictionary *)response{
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:response];
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    [txnController dismissViewControllerAnimated:YES completion:nil];
    
}

//Called when a transaction is Canceled by User. response dictionary will be having details about Canceled Transaction.
- (void)didCancelTransaction:(PGTransactionViewController *)controller
                       error:(NSError *)error
                    response:(NSDictionary *)response{
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:response];
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    [txnController dismissViewControllerAnimated:YES completion:nil];
}
@end
