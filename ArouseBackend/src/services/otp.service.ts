import axios from 'axios';
import { msg91Config } from '../config/env';

const MSG91_BASE_URL = 'https://api.msg91.com/api/v5';

const ensureMsg91Config = () => {
  if (!msg91Config.authkey || !msg91Config.templateId) {
    throw new Error('MSG91 authkey or templateId missing');
  }
};

export const normalizePhone = (phone: string): string => {
  const digits = phone.replace(/\D/g, '');
  // India numbers must be exactly 10 digits
  if (digits.length === 10) {
    return `91${digits}`;
  }

  // Already with country code
  if (digits.startsWith('91') && digits.length === 12) {
    return digits;
  }

  throw new Error('Invalid Indian phone number');
};

export async function sendOtp(phone: string) {
  ensureMsg91Config();

  const mobile = normalizePhone(phone);

  const response = await axios.post(
    `${MSG91_BASE_URL}/otp`,
    {
      mobile,
      template_id: msg91Config.templateId,
      otp_expiry: Number(msg91Config.otpExpiry || 5),
      otp_length: 6,
    },
    {
      headers: {
        authkey: msg91Config.authkey,
        'Content-Type': 'application/json',
      },
    }
  );
  return response.data;
}

export async function verifyOtp(phone: string, otp: string) {
  ensureMsg91Config();

  const mobile = normalizePhone(phone);

  const response = await axios.post(
    `${MSG91_BASE_URL}/otp/verify`,
    {
      mobile,
      otp,
    },
    {
      headers: {
        authkey: msg91Config.authkey,
        'Content-Type': 'application/json',
      },
    }
  );

  return response.data;
}
