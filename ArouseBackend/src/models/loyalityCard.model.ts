import { Schema, model, Types, Document } from "mongoose";

export interface ILoyaltyCard extends Document {
  userId: Types.ObjectId;
  cardNumber: string;
  cvv7Hash: string;
  status: "ACTIVE" | "BLOCKED" | "EXPIRED" | "DEACTIVATED";
  issueDate: Date;
  validTill: Date;
  yearlyIncome: number;
  autoRenew: boolean;
  lastRenewedAt?: Date;
  blockedReason?: string;
  deactivatedReason?: string;
  inactivityYears?: number;
  isFake: boolean;
  activatedBy: "PAYMENT" | "ADMIN" | "DEV";
}

const LoyaltyCardSchema = new Schema<ILoyaltyCard>(
  {
    userId: { type: Schema.Types.ObjectId, ref: "User", required: true, index: true },
    cardNumber: { type: String, required: true, unique: true, index: true },
    cvv7Hash: { type: String, required: true, select: false },
    status: {
      type: String,
      enum: ["ACTIVE", "BLOCKED", "EXPIRED", "DEACTIVATED"],
      default: "ACTIVE",
      index: true,
    },
    issueDate: { type: Date, required: true },
    validTill: { type: Date, required: true, index: true },
    yearlyIncome: { type: Number, required: true },
    autoRenew: { type: Boolean, default: false },
    lastRenewedAt: Date,
    blockedReason: String,
    deactivatedReason: String,
    inactivityYears: { type: Number, default: 0 },

    // 👇 New fields for fake cards
    isFake: { type: Boolean, default: false },
    activatedBy: { type: String, enum: ["PAYMENT", "ADMIN", "DEV"], default: "DEV" },
  },
  { timestamps: true }
);

LoyaltyCardSchema.index({ userId: 1 }, { unique: true });
LoyaltyCardSchema.index({ status: 1, validTill: 1 });

export default model<ILoyaltyCard>("LoyaltyCard", LoyaltyCardSchema);
