import { Schema, model, Types, Document } from "mongoose";

export interface ILoyaltyPayment extends Document {
  userId: Types.ObjectId;

  amount: number;               // 449
  currency: string;             // INR

  method: "ONLINE" | "CASH" | "UPI" | "CARD";
  provider?: "RAZORPAY" | "STRIPE" | "MANUAL";

  transactionId?: string;       // gateway txn id
  orderId?: string;             // payment order id

  status: "PENDING" | "SUCCESS" | "FAILED";
  paidAt?: Date;

  remarks?: string;
}

const LoyaltyPaymentSchema = new Schema<ILoyaltyPayment>(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true,
    },

    amount: {
      type: Number,
      required: true,
      default: 449,
    },

    currency: {
      type: String,
      default: "INR",
    },

    method: {
      type: String,
      enum: ["ONLINE", "CASH", "UPI", "CARD"],
      required: true,
    },

    provider: {
      type: String,
      enum: ["RAZORPAY", "STRIPE", "MANUAL"],
    },

    transactionId: String,
    orderId: String,

    status: {
      type: String,
      enum: ["PENDING", "SUCCESS", "FAILED"],
      default: "PENDING",
    },

    paidAt: Date,

    remarks: String,
  },
  {
    timestamps: true,
  }
);

export default model<ILoyaltyPayment>("LoyaltyPayment", LoyaltyPaymentSchema);
