import mongoose from "mongoose";

const contactUsSchema = new mongoose.Schema({
  name: { type: String },
  email: { type: String, required: true },
  subject: { type: String, required: true },
  message: { type: String, required: true },
  createdAt: { type: Date, default: Date.now },
});

export default mongoose.model("ContactUs", contactUsSchema);
