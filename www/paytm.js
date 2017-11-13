module.exports = {
  startPayment: function(orderId, customerId, email, phone, amount, successCallback, failureCallback) {
  	debugger;
    cordova.exec(successCallback,
                 failureCallback, 
                 "PayTM",
                 "startPayment",
                 [orderId, customerId, email, phone, amount]);
  }
};