import { Schema, model, Types } from "mongoose";

const inventorySchema = new Schema(
  {
    vehicle: {
      type: Types.ObjectId,
      ref: "Vehicle",
      required: true,
      index: true,
    },

    modelName: {
      type: String,
      required: true,
      index: true,
    },

    variant: {
      type: String,
      default: "default",
      index: true,
    },

    stock: {
      type: Number,
      default: 0,
    },

    location: {
      type: String,
      default: "Main Yard",
    },

    isActive: {
      type: Boolean,
      default: true,
    },
  },
  { timestamps: true }
);

/* 🔒 Prevent duplicate inventory rows */
inventorySchema.index(
  { vehicle: 1, modelName: 1, variant: 1, location: 1 },
  { unique: true }
);

export default model("Inventory", inventorySchema);
