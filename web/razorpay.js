function openRazorpay(options) {
//  console.log('openRazorpay called with options:', options); // Debug log
  const rzp = new Razorpay(options);
  rzp.open();
}