import mongoose, { Schema, model, Types, Document } from "mongoose";

export interface IBooking extends Document {
  bookingId: string;
  userId: Types.ObjectId;

  bookingDate: Date;
  status: "pending" | "confirmed" | "cancelled";

  vehicle: {
    vehicleId: Types.ObjectId;
    name: string;
    brand: string;
    variant?: string;
    fuelType?: string;
    transmission?: string;
    image?: string;
    selectedColor?: string;
    price?: number;
  };

  bookingType: string;
  branch?: {
    state?: string;
    city?: string;
    branch?: string;
  };
  currentAddress?: {
    AddressLine1: string;
    AddressLine2?: string;
    city: string;
    state: string;
    zipCode: string;
  };

  permanentAddress?: {
    AddressLine1: string;
    AddressLine2?: string;
    city: string;
    state: string;
    zipCode: string;
  };

  selectedRto?: string;
  financeDetails?: {
    financeProvider?: string;
    loanAmount?: number;
    interestRate?: number;
    tenureMonths?: number;
  };

  insuranceDetails?: {
    provider?: string;
    amount?: number;
  };

  addons?: Array<{
    name: string;
    price: number;
  }>;
  accessories?: Array<{
    name: string;
    price: number;
  }>;
  amountPaid: number;
  dealerDetails?: {
    dealerId: Types.ObjectId;
    name: string;
    contactNumber: string;
    email: string;
    address: string;
  };

}

const bookingSchema = new Schema<IBooking>(
  {
    bookingId: { type: String, required: true, unique: true },

    userId: { type: Schema.Types.ObjectId, ref: "User", required: true },

    bookingDate: { type: Date, required: true },

    status: {
      type: String,
      enum: ["pending", "confirmed", "cancelled"],
      default: "pending",
    },

    vehicle: {
      vehicleId: { type: Schema.Types.ObjectId, ref: "Vehicle", required: true },
      name: { type: String, required: true },
      brand: { type: String, required: true },
      variant: String,
      fuelType: String,
      transmission: String,
      selectedColor: String,
      image: String,
      price: { type: Number, required: true },
    },




    bookingType: { type: String, default: "Standard Market" },
    branch: {
      state: { type: String },
      city: { type: String },
      branch: { type: String },
    },
    currentAddress: {
      AddressLine1: { type: String },
      AddressLine2: { type: String },
      city: { type: String },
      state: { type: String },
      zipCode: { type: String },
    },

    permanentAddress: {
      AddressLine1: { type: String },
      AddressLine2: { type: String },
      city: { type: String },
      state: { type: String },
      zipCode: { type: String },
    },

    selectedRto: { type: String },

    financeDetails: {
      financeProvider: { type: String },
      loanAmount: { type: Number },
      interestRate: { type: Number },
      tenureMonths: { type: Number },
    },

    insuranceDetails: {
      provider: { type: String },
      amount: { type: Number },
    },

    addons: [
      {
        name: { type: String },
        price: { type: Number },
      },
    ],
    accessories: [
      {
        name: { type: String },
        price: { type: Number },
      },
    ],
    amountPaid: { type: Number, default: 0 },

    dealerDetails: {
      dealerId: { type: Schema.Types.ObjectId, ref: "Dealer" },
      name: { type: String },
      contactNumber: { type: String },
      email: { type: String },
      address: { type: String },
    },

  },
  { timestamps: true }
);


const Booking =
  mongoose.models.Booking ||
  mongoose.model<IBooking>("Booking", bookingSchema);

export default Booking;