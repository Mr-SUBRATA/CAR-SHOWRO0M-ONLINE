import { Schema, model, Document } from "mongoose";

export interface IEmiOffer extends Document {
  name: string;
  phone: string;
  selectedDealer: string;
  createdAt: Date;
}

const EmiOfferSchema = new Schema<IEmiOffer>(
  {
    name: {
      type: String,
      required: true,
      trim: true,
    },

    phone: {
      type: String,
      required: true,
      match: [/^[6-9]\d{9}$/, "Invalid phone number"],
    },

    selectedDealer: {
      type: String,
      trim: true,
    },
  },
  {
    timestamps: true,
  }
);

export default model<IEmiOffer>("EmiOffer", EmiOfferSchema);
