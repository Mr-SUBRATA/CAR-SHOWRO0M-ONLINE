import { Schema, model, Document } from "mongoose";

export interface ReviewDocument extends Document {
  username: string;
  occupation?: string;
  image?: string;
  feedback: string;
  rating: number;
  createdAt: Date;
  updatedAt: Date;
}

const reviewSchema = new Schema<ReviewDocument>(
  {
    username: { type: String, required: true, trim: true },
    occupation: { type: String },
    image: { type: String },
    feedback: { type: String, required: true, minlength: 3, maxlength: 500 },
    rating: { type: Number, required: true, min: 1, max: 5 },
  },
  { timestamps: true }
);

export const ReviewModel = model<ReviewDocument>("Review", reviewSchema);
