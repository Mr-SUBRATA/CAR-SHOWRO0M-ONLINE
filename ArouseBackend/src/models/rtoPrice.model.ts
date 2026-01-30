import { Schema, model, Document } from 'mongoose';

export interface IRtoMaster extends Document {
  state: string;
  city: string;
  rtoCode?: string;        // ex: MH01, DL04 etc
  fuelTypeTaxes: Record<string, number>; // allows dynamic keys
  registrationFee: number;
  plateFee: number;
  handlingCharges: number;
  insurance: number;
  otherCharges: number;
}

const rtoMasterSchema = new Schema<IRtoMaster>(
  {
    state: { type: String },
    city: { type: String, required: true },
    rtoCode: { type: String },

    fuelTypeTaxes: {
      type: Map,
      of: Number,
      default: {},
    },
    registrationFee: { type: Number, default: 0 },
    plateFee: { type: Number, default: 0 },
    handlingCharges: { type: Number, default: 0 },
    insurance: { type: Number, default: 0 },
    otherCharges: { type: Number, default: 0 },
  },
  { timestamps: true },
);

rtoMasterSchema.index({ state: 1, city: 1 }, { unique: true });

const RtoMaster = model<IRtoMaster>('RtoMaster', rtoMasterSchema);
export default RtoMaster;
