import { Schema, model, Document, Types } from "mongoose";

export interface ISale extends Document {
  vehicle: Types.ObjectId;
  vehicleName: string;
  variant?: string;
  customerName: string;
  phone?: string;
  address?: string;
  source?: string;
  quantity: number;
}

const SaleSchema = new Schema<ISale>(
  {
    vehicle: { type: Schema.Types.ObjectId, ref: "Vehicle", required: true },
    vehicleName: {
      type: String,
      required: true,
      trim: true,
    },
    variant: { type: String },
    customerName: { type: String, required: true },
    phone: { type: String },
    address: { type: String },
    source: { type: String },
    quantity: { type: Number, default: 1 },
  },
  { timestamps: true }
);

export default model<ISale>("Sale", SaleSchema);
