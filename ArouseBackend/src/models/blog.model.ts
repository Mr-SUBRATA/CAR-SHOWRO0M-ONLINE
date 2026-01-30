import { Schema, model, Document } from "mongoose";

export interface IBlog extends Document {
  title: string;
  slug: string;
  tag?: string;
  excerpt?: string;
  content: string;
  author?: string;
  image?: {
    data: Buffer;
    contentType: string;
  };
}

const blogSchema = new Schema<IBlog>(
  {
    title: { type: String, required: true },
    slug: { type: String, required: true, unique: true },
    tag: { type: String },
    excerpt: { type: String },
    content: { type: String, required: true },
    author: { type: String },
    image: {
      data: Buffer,
      contentType: String,
    },
  },
  { timestamps: true }
);

export default model<IBlog>("Blog", blogSchema);



// import { Schema, model, Document } from "mongoose";

// export interface IBlog extends Document {
//   title: string;
//   slug: string;
//   tag?: string;
//   excerpt?: string;
//   content: string;
//   author?: string;
//   image?: {
//     url: string;         // S3 URL
//     contentType?: string; // optional MIME type
//   };
// }

// const blogSchema = new Schema<IBlog>(
//   {
//     title: { type: String, required: true },
//     slug: { type: String, required: true, unique: true },
//     tag: { type: String },
//     excerpt: { type: String },
//     content: { type: String, required: true },
//     author: { type: String },
//     image: {
//       url: { type: String },         // S3 URL
//       contentType: { type: String }, // optional
//     },
//   },
//   { timestamps: true }
// );

// export default model<IBlog>("Blog", blogSchema);
