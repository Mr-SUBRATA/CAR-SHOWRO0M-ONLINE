import { Schema, model, Types, Document } from "mongoose";

export interface IPointsLedger extends Document {
  userId: Types.ObjectId;
  type:
    | "LOYALTY"
    | "INDIRECT"
    | "REFERRAL"
    | "ADDITIONAL_REWARD"
    | "REDEEM"
    | "DEBIT"
    | "CARD_RENEWAL";
  points: number;
  source?: "LMC" | "REFERRAL" | "SYSTEM";
  description?: string;
  referenceId?: Types.ObjectId;
  orbitNo?: number;
  month: string; // YYYY-MM
  isReversed?: boolean;
}

const PointsLedgerSchema = new Schema<IPointsLedger>(
  {
    userId: { type: Schema.Types.ObjectId, ref: "User", required: true, index: true },
    type: {
      type: String,
      enum: [
        "LOYALTY",
        "INDIRECT",
        "REFERRAL",
        "ADDITIONAL_REWARD",
        "REDEEM",
        "DEBIT",
        "CARD_RENEWAL",
      ],
      required: true,
    },
    points: { type: Number, required: true },
    source: { type: String, enum: ["LMC", "REFERRAL", "SYSTEM"] },
    description: String,
    referenceId: { type: Schema.Types.ObjectId, index: true },
    orbitNo: Number,
    month: { type: String, required: true, index: true },
    isReversed: { type: Boolean, default: false },
  },
  { timestamps: true }
);

PointsLedgerSchema.index(
  { userId: 1, type: 1, referenceId: 1 },
  { unique: true, partialFilterExpression: { referenceId: { $exists: true } } }
);
PointsLedgerSchema.index({ userId: 1, month: 1 });
PointsLedgerSchema.index({ userId: 1, orbitNo: 1 });

export default model<IPointsLedger>("PointsLedger", PointsLedgerSchema);
