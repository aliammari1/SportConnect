export function calculateFees(amount: number) {
  const platformFee = Math.round(amount * 0.15);
  const driverAmount = amount - platformFee;
  return { platformFee, driverAmount };
}
