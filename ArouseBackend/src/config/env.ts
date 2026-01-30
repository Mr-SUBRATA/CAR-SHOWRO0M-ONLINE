import dotenv from 'dotenv';

dotenv.config();

const missingMsg91Vars = ['MSG91_AUTHKEY', 'MSG91_TEMPLATE_ID'].filter(
  (key) => !process.env[key],
);

if (missingMsg91Vars.length) {
  // Warn instead of throwing to avoid breaking non-OTP flows, but surface clearly in logs.
  // eslint-disable-next-line no-console
  console.warn(`MSG91 config missing env vars: ${missingMsg91Vars.join(', ')}`);
}

export const msg91Config = {
  authkey: process.env.MSG91_AUTHKEY || '',
  templateId: process.env.MSG91_TEMPLATE_ID || '',
  otpExpiry: process.env.MSG91_OTP_EXPIRY || '',
  retryType: process.env.MSG91_RETRY_TYPE || 'text',
  senderId: process.env.MSG91_SENDER_ID || '',
};

const parseList = (value?: string): string[] =>
  (value || '')
    .split(',')
    .map((item) => item.trim())
    .filter(Boolean);

export const appConfig = {
  mongoUri: process.env.MONGO_URI!,
  jwtSecret: process.env.JWT_SECRET || '',
  adminSignupCode: process.env.ADMIN_SIGNUP_CODE || '',
  adminEmails: parseList(process.env.ADMIN_EMAIL_WHITELIST).map((email) => email.toLowerCase()),
  adminPhones: parseList(process.env.ADMIN_PHONE_WHITELIST),
};
