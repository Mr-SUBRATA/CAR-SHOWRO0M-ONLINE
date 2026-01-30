import { Schema, model, Document } from 'mongoose';

// Canonical brand/type lists for UI filters and validation.
export const BRANDS = [
  'Toyota',
  'Porsche',
  'Audi',
  'BMW',
  'Ford',
  'Nissan',
  'Peugeot',
  'Volkswagen',
];

export const VEHICLE_TYPES = [
  'Sedan',
  'Hatchback',
  'SUV',
  'Hybrid',
  'Electric',
  'Coupe',
  'Truck',
  'Convertible',
];

export interface IVehicle extends Document {
  name: string;
  brand: string;
  type: string;
  price: number;
  fuelType: string;
  transmission: string;
  engine?: string;
  engineType?: string;
  displacementCc?: string;
  maxPower?: string;
  maxTorque?: string;
  brochureUrl?: string;
  safety?: string[];
  specifications?: {
    overview?: string[];
    dimension?: string[];
    wheels?: string[];
    performance?: string[];
    technology?: string[];
  };
  features?: Array<{
    image: {
      filename?: string;
      data: Buffer;
      contentType: string;
      url?: string;
    };
    title?: string;
    caption?: string;
  }>;
  brochureFiles?: Array<{
    filename?: string;
    data?: Buffer;
    contentType?: string;
    url?: string;
  }>;
  colorImages?: Array<{
    color: string;
    images: string[];
  }>;
  variants?: Array<{
    _id?: string;
    name: string;
    fuelType?: string;
    transmission?: string;
    engineType?: string;
    displacementCc?: string;
    maxPower?: string;
    maxTorque?: string;
    price: number;
    images?: string[];
    colors?: string[];
    features?: Array<{
      image: string;
      title?: string;
      caption?: string;
    }>;
    colorImages?: Array<{
      color: string;
      images: string[];
    }>;
    brochureUrl?: string;
    safety?: string[];
    specifications?: {
      overview?: string[];
      dimension?: string[];
      wheels?: string[];
      performance?: string[];
      technology?: string[];
    };
  }>;
  colors?: string[];
  isFeatured: boolean;
  isLuxury: boolean;
  images: Array<{
    filename?: string;
    data: Buffer;
    contentType: string;
    url?: string; // backwards compatibility if some entries remain URLs
  }>;
  testDriveAvailable?: boolean;
}

const vehicleSchema = new Schema<IVehicle>(
  {
    name: { type: String, required: true },
    brand: { type: String, required: true },
    type: { type: String, required: true },
    price: { type: Number, required: true },
    fuelType: { type: String, required: true },
    transmission: { type: String, required: true },
    engine: { type: String },
    engineType: { type: String },
    displacementCc: { type: String },
    maxPower: { type: String },
    maxTorque: { type: String },
    brochureUrl: { type: String },
    brochureFiles: [
      {
        filename: { type: String },
        data: { type: Buffer },
        contentType: { type: String },
        url: { type: String },
      },
    ],
    safety: [{ type: String }],
    specifications: {
      overview: [{ type: String }],
      dimension: [{ type: String }],
      wheels: [{ type: String }],
      performance: [{ type: String }],
      technology: [{ type: String }],
    },
    features: [
      {
        image: {
          type: new Schema(
            {
              filename: String,
              data: { type: Buffer, required: true },
              contentType: { type: String, required: true },
              url: String,
            },
            { _id: false },
          ),
          required: true,
        },
        title: { type: String },
        caption: { type: String },
      },
    ],
    colorImages: [
      {
        color: { type: String, required: true },
        images: [{ type: String, required: true }],
      },
    ],
    variants: [
      {
        name: { type: String, required: true },
        fuelType: { type: String },
        transmission: { type: String },
        engineType: { type: String },
        displacementCc: { type: String },
        maxPower: { type: String },
        maxTorque: { type: String },
        price: { type: Number, required: true },
        images: [{ type: String }],
        colors: [{ type: String }],
        features: [
          {
            image: { type: String, required: true },
            title: { type: String },
            caption: { type: String },
          },
        ],
        colorImages: [
          {
            color: { type: String, required: true },
            images: [{ type: String, required: true }],
          },
        ],
        brochureUrl: { type: String },
        safety: [{ type: String }],
        specifications: {
          overview: [{ type: String }],
          dimension: [{ type: String }],
          wheels: [{ type: String }],
          performance: [{ type: String }],
          technology: [{ type: String }],
        },
      },
    ],
    colors: [{ type: String }],
    isFeatured: { type: Boolean, default: false },
    isLuxury: { type: Boolean, default: false },
    images: [
      {
        filename: { type: String },
        data: { type: Buffer },
        contentType: { type: String },
        url: { type: String }, // support legacy URL entries if present
      },
    ],
  testDriveAvailable: { type: Boolean, default: true },
  },
  { timestamps: true },
);

vehicleSchema.index({ name: 'text', brand: 'text' });

const Vehicle = model<IVehicle>('Vehicle', vehicleSchema);

export default Vehicle;


// import { Schema, model, Document } from 'mongoose';

// // Canonical brand/type lists for UI filters and validation.
// export const BRANDS = [
//   'Toyota',
//   'Porsche',
//   'Audi',
//   'BMW',
//   'Ford',
//   'Nissan',
//   'Peugeot',
//   'Volkswagen',
// ];

// export const VEHICLE_TYPES = [
//   'Sedan',
//   'Hatchback',
//   'SUV',
//   'Hybrid',
//   'Electric',
//   'Coupe',
//   'Truck',
//   'Convertible',
// ];

// export interface IVehicle extends Document {
//   name: string;
//   brand: string;
//   type: string;
//   price: number;
//   fuelType: string;
//   transmission: string;
//   engine?: string;
//   engineType?: string;
//   displacementCc?: string;
//   maxPower?: string;
//   maxTorque?: string;
//   brochureUrl?: string;
//   safety?: string[];
//   specifications?: {
//     overview?: string[];
//     dimension?: string[];
//     wheels?: string[];
//     performance?: string[];
//     technology?: string[];
//   };
//   features?: Array<{
//     image: string; // S3 URL
//     title?: string;
//     caption?: string;
//   }>;

//   brochureFiles?: Array<{
//     filename?: string;
//     url: string; // S3 URL
//   }>;
//   colorImages?: Array<{
//     color: string;
//     images: string[];
//   }>;
//   variants?: Array<{
//     _id?: string;
//     name: string;
//     fuelType?: string;
//     transmission?: string;
//     engineType?: string;
//     displacementCc?: string;
//     maxPower?: string;
//     maxTorque?: string;
//     price: number;
//     images?: string[];
//     colors?: string[];
//     features?: Array<{
//       image: string;
//       title?: string;
//       caption?: string;
//     }>;
//     colorImages?: Array<{
//       color: string;
//       images: string[];
//     }>;
//     brochureUrl?: string;
//     safety?: string[];
//     specifications?: {
//       overview?: string[];
//       dimension?: string[];
//       wheels?: string[];
//       performance?: string[];
//       technology?: string[];
//     };
//   }>;
//   colors?: string[];
//   isFeatured: boolean;
//   isLuxury: boolean;
//   images: string[];
//   testDriveAvailable?: boolean;
// }

// const vehicleSchema = new Schema<IVehicle>(
//   {
//     name: { type: String, required: true },
//     brand: { type: String, required: true },
//     type: { type: String, required: true },
//     price: { type: Number, required: true },
//     fuelType: { type: String, required: true },
//     transmission: { type: String, required: true },
//     engine: { type: String },
//     engineType: { type: String },
//     displacementCc: { type: String },
//     maxPower: { type: String },
//     maxTorque: { type: String },
//     brochureUrl: { type: String },
//     brochureFiles: [
//       {
//         filename: String,
//         url: { type: String, required: true }, // S3 URL
//       },
//     ],
//     safety: [{ type: String }],
//     specifications: {
//       overview: [{ type: String }],
//       dimension: [{ type: String }],
//       wheels: [{ type: String }],
//       performance: [{ type: String }],
//       technology: [{ type: String }],
//     },
//     features: [
//       {
//         image: { type: String, required: true }, // S3 URL
//         title: String,
//         caption: String,
//       },
//     ],
//     colorImages: [
//       {
//         color: { type: String, required: true },
//         images: [{ type: String, required: true }],
//       },
//     ],
//     variants: [
//       {
//         name: { type: String, required: true },
//         fuelType: { type: String },
//         transmission: { type: String },
//         engineType: { type: String },
//         displacementCc: { type: String },
//         maxPower: { type: String },
//         maxTorque: { type: String },
//         price: { type: Number, required: true },
//         images: [String],
//         colors: [{ type: String }],
//         features: [
//           {
//             image: { type: String, required: true },
//             title: { type: String },
//             caption: { type: String },
//           },
//         ],
//         colorImages: [
//           {
//             color: { type: String, required: true },
//             images: [{ type: String, required: true }],
//           },
//         ],
//         brochureUrl: { type: String },
//         safety: [{ type: String }],
//         specifications: {
//           overview: [{ type: String }],
//           dimension: [{ type: String }],
//           wheels: [{ type: String }],
//           performance: [{ type: String }],
//           technology: [{ type: String }],
//         },
//       },
//     ],
//     colors: [{ type: String }],
//     isFeatured: { type: Boolean, default: false },
//     isLuxury: { type: Boolean, default: false },
//     images: [{ type: String, required: true }], // S3 URLs

//     testDriveAvailable: { type: Boolean, default: true },
//   },
//   { timestamps: true },
// );

// vehicleSchema.index({ name: 'text', brand: 'text' });

// const Vehicle = model<IVehicle>('Vehicle', vehicleSchema);

// export default Vehicle;
