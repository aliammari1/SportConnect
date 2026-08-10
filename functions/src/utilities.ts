export function mapPayoutStatus(status: string | null | undefined): string {
  switch (status) {
    case "pending":
      return "pending";
    case "in_transit":
      return "inTransit";
    case "paid":
      return "paid";
    case "failed":
      return "failed";
    case "canceled":
      return "cancelled";
    default:
      return "pending";
  }
}
