# Paytm-integration-in-ios-ionic2-and-ionic3
Steps for integrating paytm in ionic2 and ionic3 in ios apps
Checksum Utilities:


https://github.com/Paytm-Payments/Paytm_App_Checksum_Kit_JAVA


Step1:
Generation of check sum in typescript file


     let body= {
     "MID":"WorldP64425807474247",
     "ORDER_ID":orderid,
     "CUST_ID":customerid,
     "INDUSTRY_TYPE_ID":"Retail",
     "CHANNEL_ID":"WAP",
     "TXN_AMOUNT":"10.0",
     "WEBSITE":"Microwap",
     "EMAIL":"***********",
     "MOBILE_NO":"***********",
     "CALLBACK_URL":"https://pguat.paytm.com/paytmchecksum/paytmCallback.jsp"
     };
     
    let data=JSON.stringify(body);
         this.http.post('https://test.com/paytm/generateChecksum.php', data, options)
     .subscribe(function(response) {
                let chesumresp=JSON.parse(response['_body']);
                let checksum=temp.CHECKSUMHASH;
             window['plugins'].paytm.startPayment(orderid, customerid, "***********", chesumresp.CHECKSUMHASH, "10.00", this.PayTmsuccessCallback, this.PayTmfailureCallback);
                        },
            function(error) { 
           console.log("Error happened: " + error);
            }
        );
        
        
       Need to generate random orderid and customer id same order id and customer id need to pass to paytm sdk
       
