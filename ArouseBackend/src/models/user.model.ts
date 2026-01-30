

import { Schema, model, Document, Types } from 'mongoose';

interface Address {
  areaPincode?: string;
  addressLine1?: string;
  addressLine2?: string;
  landmark?: string;
  city?: string;
  state?: string;
}

interface BankDetails {
  accountNumber?: string;
  accountName?: string;
  ifscCode?: string;
  bankName?: string;
  branch?: string;
}

interface KycInfo {
  status: 'not_started' | 'in_progress' | 'verified';
  drivingLicenseUploaded: boolean;
  nationalIdUploaded: boolean;
  selfieUploaded: boolean;
}

export interface IUser extends Document {
  name: string;
  email: string;
  phone: string;
  role: 'user' | 'admin';
  emailVerified: boolean;
  profilePhoto?: string;
  profilePhotoMimeType?: string;
  phoneVerified: boolean;
  occupation?: string;
  password?: string;
  panNumber?: string;
  aadharNumber?: string;
  aadharVerified: boolean;
  panVerified: boolean;
  kyc: KycInfo;
  currentAddress?: Address;
  permanentAddress?: Address;
  bankDetails?: BankDetails;
  compareList: Types.ObjectId[];
}

const addressSchema = new Schema<Address>(
  {
    areaPincode: String,
    addressLine1: String,
    addressLine2: String,
    landmark: String,
    city: String,
    state: String,
  },
  { _id: false },
);

const bankDetailsSchema = new Schema<BankDetails>(
  {
    accountNumber: String,
    accountName: String,
    ifscCode: String,
    bankName: String,
    branch: String,
  },
  { _id: false },
);

const kycSchema = new Schema<KycInfo>(
  {
    status: {
      type: String,
      enum: ['not_started', 'in_progress', 'verified'],
      default: 'not_started',
    },
    drivingLicenseUploaded: { type: Boolean, default: false },
    nationalIdUploaded: { type: Boolean, default: false },
    selfieUploaded: { type: Boolean, default: false },
  },
  { _id: false },
);

const userSchema = new Schema<IUser>(
  {
    name: { type: String, required: true },
    email: { type: String },
    phone: { type: String, required: true, unique: true },
    role: { type: String, enum: ['user', 'admin'], default: 'user' },
    occupation: { type: String },
    panNumber: { type: String },
    aadharNumber: { type: String },
    profilePhoto: {
      type: String, default: null,
      select: false
    },
    profilePhotoMimeType: {
      type: String, default: null,
    },
    password: {
      type: String,
      select: false,
    },

    panVerified: { type: Boolean, default: false },
    aadharVerified: { type: Boolean, default: false },
    emailVerified: { type: Boolean, default: false },
    phoneVerified: { type: Boolean, default: false },
    currentAddress: { type: addressSchema, default: {} },
    permanentAddress: { type: addressSchema, default: {} },
    bankDetails: { type: bankDetailsSchema, default: {} },
    kyc: { type: kycSchema, default: {} },
    compareList: [{ type: Schema.Types.ObjectId, ref: 'Vehicle' }],
  },
  { timestamps: true },
);

export default model<IUser>('User', userSchema);


// import { Schema, model, Document, Types } from 'mongoose';

// interface Address {
//   areaPincode?: string;
//   addressLine1?: string;
//   addressLine2?: string;
//   landmark?: string;
//   city?: string;
//   state?: string;
// }

// interface BankDetails {
//   accountNumber?: string;
//   accountName?: string;
//   ifscCode?: string;
//   bankName?: string;
//   branch?: string;
// }

// interface KycInfo {
//   status: 'not_started' | 'in_progress' | 'verified';
//   drivingLicense?: string; // S3 URL
//   nationalId?: string;     // S3 URL
//   selfie?: string;
// }

// export interface IUser extends Document {
//   name: string;
//   email: string;
//   phone: string;
//   role: 'user' | 'admin';
//   emailVerified: boolean;
//   profilePhoto?: string; // ✅ S3 URL
//   profilePhotoMimeType?: string;
//   phoneVerified: boolean;
//   occupation?: string;
//   password?: string;
//   panNumber?: string;
//   aadharNumber?: string;
//   aadharVerified: boolean;
//   panVerified: boolean;
//   kyc: KycInfo;
//   currentAddress?: Address;
//   permanentAddress?: Address;
//   bankDetails?: BankDetails;
//   compareList: Types.ObjectId[];
// }

// const addressSchema = new Schema<Address>(
//   {
//     areaPincode: String,
//     addressLine1: String,
//     addressLine2: String,
//     landmark: String,
//     city: String,
//     state: String,
//   },
//   { _id: false },
// );

// const bankDetailsSchema = new Schema<BankDetails>(
//   {
//     accountNumber: String,
//     accountName: String,
//     ifscCode: String,
//     bankName: String,
//     branch: String,
//   },
//   { _id: false },
// );

// const kycSchema = new Schema<KycInfo>(
//   {
//     status: {
//       type: String,
//       enum: ['not_started', 'in_progress', 'verified'],
//       default: 'not_started',
//     },
//     drivingLicense: { type: String }, // S3 URL
//     nationalId: { type: String },     // S3 URL
//     selfie: { type: String },
//   },
//   { _id: false },
// );

// const userSchema = new Schema<IUser>(
//   {
//     name: { type: String, required: true },
//     email: { type: String },
//     phone: { type: String, required: true, unique: true },
//     role: { type: String, enum: ['user', 'admin'], default: 'user' },
//     occupation: { type: String },
//     panNumber: { type: String },
//     aadharNumber: { type: String },
//     profilePhoto: {
//       type: String,
//     },
//     profilePhotoMimeType: {
//       type: String, default: null,
//     },
//     password: {
//       type: String,
//       select: false,
//     },

//     panVerified: { type: Boolean, default: false },
//     aadharVerified: { type: Boolean, default: false },
//     emailVerified: { type: Boolean, default: false },
//     phoneVerified: { type: Boolean, default: false },
//     currentAddress: { type: addressSchema, default: {} },
//     permanentAddress: { type: addressSchema, default: {} },
//     bankDetails: { type: bankDetailsSchema, default: {} },
//     kyc: { type: kycSchema, default: {} },
//     compareList: [{ type: Schema.Types.ObjectId, ref: 'Vehicle' }],
//   },
//   { timestamps: true },
// );

// export default model<IUser>('User', userSchema);
