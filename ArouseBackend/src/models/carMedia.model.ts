import { Schema, model, Document } from 'mongoose';

export interface ICarMedia extends Document {
  filename: string;
  contentType: string;
  data: Buffer;
  kind?: string; // image|media
  carId?: string;
  title?: string;
  caption?: string;
}

const carMediaSchema = new Schema<ICarMedia>(
  {
    filename: { type: String, required: true },
    contentType: { type: String, required: true },
    data: { type: Buffer, required: true },
    kind: { type: String },
    carId: { type: Schema.Types.ObjectId, ref: 'Vehicle' },
    title: { type: String },
    caption: { type: String },
  },
  { timestamps: true },
);

const CarMedia = model<ICarMedia>('CarMedia', carMediaSchema);

export default CarMedia;
