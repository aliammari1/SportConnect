import 'package:cloud_functions/cloud_functions.dart';

/// Converts raw Stripe / Firebase Functions errors into
/// short, human-readable messages safe to show in the UI.
class PaymentErrorHandler {
  const PaymentErrorHandler._();

  static String humanize(Object error) {
    if (error is FirebaseFunctionsException) {
      return _fromFunctionsException(error);
    }
    return _fromRawMessage(error.toString());
  }

  static String _fromFunctionsException(FirebaseFunctionsException e) {
    final message = e.message ?? '';

    switch (e.code) {
      case 'unauthenticated':
        return 'Please sign in to continue.';
      case 'not-found':
        return 'This payment or payout could not be found.';
      case 'already-exists':
        return 'This request was already processed.';
      case 'resource-exhausted':
        return 'Too many requests — please wait a moment and try again.';
      case 'deadline-exceeded':
        return 'The request timed out. Please check your connection and try again.';
      case 'unavailable':
        return 'Service temporarily unavailable. Please try again.';
      case 'permission-denied':
        if (message.toLowerCase().contains('stripe account')) {
          return 'Security check failed. Please refresh and try again.';
        }
        return "You don't have permission to do this.";
      case 'failed-precondition':
        return _fromRawMessage(message);
    }

    return _fromRawMessage(message);
  }

  static String _fromRawMessage(String message) {
    final lower = message.toLowerCase();

    if (lower.contains('insufficient') && lower.contains('balance')) {
      return 'Insufficient balance. Ride earnings may still be settling — try again in a few hours.';
    }
    if (lower.contains('no payout destination') ||
        lower.contains('external account')) {
      return 'No bank account linked. Please complete your Stripe setup first.';
    }
    if (lower.contains('payouts are not enabled') ||
        lower.contains('payouts_not_allowed')) {
      return 'Payouts not yet enabled on your account. Please complete verification.';
    }
    if (lower.contains('charges are not enabled') ||
        lower.contains('charges_not_enabled')) {
      return "Your Stripe account isn't fully activated yet. Complete your setup to accept payments.";
    }
    if (lower.contains('account is not fully activated') ||
        lower.contains('account verification')) {
      return "Tap 'Complete Setup' to finish verifying your payout account.";
    }
    if (lower.contains('card_declined') ||
        lower.contains('card was declined')) {
      return 'Your card was declined. Please try a different payment method.';
    }
    if (lower.contains('insufficient_funds') ||
        lower.contains('insufficient funds')) {
      return 'Payment declined — insufficient funds on your card.';
    }
    if (lower.contains('expired_card') || lower.contains('expired card')) {
      return 'Your card has expired. Please update your payment method.';
    }
    if (lower.contains('incorrect_cvc') || lower.contains('incorrect cvc')) {
      return 'Incorrect card security code. Please check and try again.';
    }
    if (lower.contains('cannot be cancelled') && lower.contains('payout')) {
      return "This payout can no longer be cancelled — it's already being processed by your bank.";
    }
    if (lower.contains('payout') && lower.contains('failed')) {
      return 'Payout failed. Please check your bank details are correct.';
    }
    if (lower.contains('refund') && lower.contains('failed')) {
      return 'Refund could not be processed. Please contact support if this persists.';
    }
    if (lower.contains('already been paid') || lower.contains('already paid')) {
      return 'This booking has already been paid.';
    }
    if (lower.contains('ride is no longer available')) {
      return 'This ride is no longer available for booking.';
    }
    if (lower.contains('no active booking')) {
      return 'No active booking found for this ride.';
    }
    if (lower.contains('driver') && lower.contains('stripe account')) {
      return "The driver hasn't finished setting up their payout account yet.";
    }
    if (lower.contains('network') ||
        lower.contains('connection') ||
        lower.contains('socket')) {
      return 'Connection error. Please check your internet and try again.';
    }
    if (lower.contains('timeout') || lower.contains('timed out')) {
      return 'Request timed out. Please try again.';
    }
    if (lower.contains('firebase') || lower.contains('exception:')) {
      return 'Something went wrong. Please try again.';
    }
    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }

    return message.isEmpty
        ? 'Something went wrong. Please try again.'
        : message;
  }
}
