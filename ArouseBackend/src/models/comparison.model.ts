import { Schema, model, Document, Types } from 'mongoose';

export interface IComparison extends Document {
  title: string;
  vehicleIds: Types.ObjectId[];
  isPublic: boolean;
  createdBy?: Types.ObjectId;
}

const comparisonSchema = new Schema<IComparison>(
  {
    title: { type: String, required: true, trim: true },
    vehicleIds: {
      type: [{ type: Schema.Types.ObjectId, ref: 'Vehicle', required: true }],
      validate: [(arr: unknown[]) => Array.isArray(arr) && arr.length >= 2 && arr.length <= 3, 'vehicleIds must have between 2 and 3 items'],
    },
    isPublic: { type: Boolean, default: false },
    createdBy: { type: Schema.Types.ObjectId, ref: 'User' },
  },
  { timestamps: true },
);

const Comparison = model<IComparison>('Comparison', comparisonSchema);

export default Comparison;
