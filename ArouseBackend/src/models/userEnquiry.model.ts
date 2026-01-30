import { Schema, model, Document } from "mongoose";

export interface IEnquiry extends Document {
  firstName: string;
  lastName: string;
  mobile: string;
  alternateMobile?: string;
  email?: string;
  currentAddress?: string;
  state?: string;
  city?: string;
  pinCode?: string;
  preferredBrand?: string;
  preferredModel?: string;
  remark?: string;
  status: "new" | "contacted" | "closed";
  createdAt: Date;
}

const EnquirySchema = new Schema<IEnquiry>(
  {
    firstName: {
      type: String,
      required: true,
      trim: true,
    },
    lastName: {
      type: String,
      required: true,
      trim: true,
    },
    mobile: {
      type: String,
      required: true,
      match: /^[6-9]\d{9}$/,
    },
    alternateMobile: {
      type: String,
      match: /^[6-9]\d{9}$/,
    },
    email: {
      type: String,
      lowercase: true,
      trim: true,
    },
    currentAddress: {
      type: String,
      trim: true,
    },
    state: {
      type: String,
      trim: true,
    },
    city: {
      type: String,
      trim: true,
    },
    pinCode: {
      type: String,
      trim: true,
    },
    preferredBrand: {
      type: String,
      trim: true,
    },
    preferredModel: {
      type: String,
      trim: true,
    },
    remark: {
      type: String,
      trim: true,
    },
    status: {
      type: String,
      enum: ["new", "contacted", "closed", "UNDER_PROCESS", "BOOKED", "DELIVERED", "LOST"],
      default: "new",
    },
  },
  { timestamps: true }
);

export default model<IEnquiry>("userEnquiry", EnquirySchema);
