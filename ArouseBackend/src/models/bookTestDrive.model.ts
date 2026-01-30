import mongoose, { Schema, model, Document, Types } from 'mongoose';

export interface IBooking extends Document {
  userId: Types.ObjectId;
  date: Date;
  timeSlot: string;
  status: "pending" | "confirmed" | "cancelled" | "completed";
  state?: string;
  city?: string;
  address?: string;
  brand: string;
  modelName: string;
  fuelType?: string;
  customerName: string;
  phoneNumber: string;
  alternatePhoneNumber?: string;
  email?: string;
  hasDrivingLicense: boolean;
}


const bookingSchema = new Schema<IBooking>(
  {
    userId: { type: Schema.Types.ObjectId, ref: "User", required: true },
    date: { type: Date, required: true },
    timeSlot: { type: String, required: true },
    state: { type: String },
    city: { type: String },
    address: { type: String },
    brand: { type: String, required: true }, // now required
    modelName: { type: String, required: true }, // now required
    fuelType: { type: String },
    customerName: { type: String, required: true }, // now required
    phoneNumber: { type: String, required: true }, // now required
    alternatePhoneNumber: { type: String },
    email: { type: String },
    hasDrivingLicense: { type: Boolean, required: true }, // now required
    status: {
      type: String,
      enum: ["pending", "confirmed", "cancelled", "completed"],
      default: "pending",
    },
  },
  { timestamps: true }
);

const BookTestDrive = mongoose.models.BookTestDrive || model<IBooking>('BookTestDrive', bookingSchema);

export default BookTestDrive;
