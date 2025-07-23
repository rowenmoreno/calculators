class CreditCardCalculatorData {
  double balance;
  double apr;
  double additionalPayment;
  double minPaymentPercent;
  double minPaymentAmount;
  bool skipDecember;
  String displayType;

  CreditCardCalculatorData({
    this.balance = 0,
    this.apr = 18,
    this.additionalPayment = 0,
    this.minPaymentPercent = 3,
    this.minPaymentAmount = 35,
    this.skipDecember = false,
    this.displayType = 'Yearly',
  });
}
