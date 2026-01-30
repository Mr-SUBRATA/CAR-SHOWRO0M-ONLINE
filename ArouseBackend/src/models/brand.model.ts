import { Schema, model, Document } from 'mongoose';

export interface IBrand extends Document {
  name: string;
  logoUrl?: string;
  isFeatured: boolean;
  priority?: number; // optional ordering for featured/explore sections
}

const brandSchema = new Schema<IBrand>(
  {
    name: { type: String, required: true, unique: true, trim: true },
    logoUrl: { type: String },
    isFeatured: { type: Boolean, default: false },
    priority: { type: Number, default: 0 },
  },
  { timestamps: true },
);

const Brand = model<IBrand>('Brand', brandSchema);

export default Brand;
