import { Schema, model, Types, Document } from "mongoose";

export interface IEnquiry extends Document {
  customerName: string;
  contactNumber: string;
  alternateNumber?: string;
  preferredBrand?: string;
  modelName?: string;
  vehicleId?: Types.ObjectId;
  userId: Types.ObjectId;
  salesPersonId?: Types.ObjectId;
  source: "LMC" | "TRANSFORMED" | "XYZ";
  status: "UNDER_PROCESS" | "BOOKED" | "DELIVERED" | "LOST";
  pointsCredited: boolean;
  lostAt?: Date;
  deliveredAt?: Date;

  // ✅ Add these for timestamps
  createdAt: Date;
  updatedAt: Date;
}

const EnquirySchema = new Schema<IEnquiry>(
  {
    customerName: { type: String, required: true },
    contactNumber: { type: String, required: true, index: true },
    alternateNumber: String,
    preferredBrand: String,
    modelName: String,
    vehicleId: { type: Schema.Types.ObjectId, ref: "Vehicle" },
    userId: { type: Schema.Types.ObjectId, ref: "User", required: true },
    salesPersonId: { type: Schema.Types.ObjectId, ref: "User" },
    source: { type: String, enum: ["LMC", "TRANSFORMED", "XYZ"], default: "LMC" },
    status: {
      type: String,
      enum: ["UNDER_PROCESS", "BOOKED", "DELIVERED", "LOST"],
      default: "UNDER_PROCESS",
    },
    pointsCredited: { type: Boolean, default: false },
    lostAt: Date,
    deliveredAt: Date,
  },
  { timestamps: true } // ✅ Enables createdAt & updatedAt
);

export default model<IEnquiry>("Enquiry", EnquirySchema);
