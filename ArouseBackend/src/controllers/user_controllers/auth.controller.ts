
import { Request, Response } from 'express';
import jwt from 'jsonwebtoken';
import User from '../../models/user.model';
import { sendOtp, verifyOtp, normalizePhone } from '../../services/otp.service';
import { appConfig } from '../../config/env';

/**
 * ======================
 * LOGIN → SEND OTP
 * ======================
 */
export const loginSendOtpHandler = async (req: Request, res: Response) => {
  const { phone } = req.body;

  if (!phone) {
    return res.status(400).json({ message: 'Phone is required' });
  }

  const normalizedPhone = normalizePhone(phone);
  const user = await User.findOne({ phone: normalizedPhone });

  if (!user) {
    return res.status(404).json({
      message: 'User not found, please signup',
    });
  }

  await sendOtp(normalizedPhone);
  return res.json({ message: 'OTP sent for login' });
};

/**
 * ======================
 * SIGNUP → SEND OTP
 * ======================
 */
export const signupSendOtpHandler = async (req: Request, res: Response) => {
  const { name, email, phone } = req.body;

  if (!name || !phone) {
    return res.status(400).json({
      message: 'Name, email & phone are required',
    });
  }

  const normalizedPhone = normalizePhone(phone);
  const exists = await User.findOne({ phone: normalizedPhone });

  if (exists) {
    return res.status(400).json({
      message: 'User already exists, please login',
    });
  }

  await sendOtp(normalizedPhone);
  return res.json({ message: 'OTP sent for signup' });
};

/**
 * ======================
 * VERIFY OTP (LOGIN + SIGNUP)
 * ======================
 */
export const verifyOtpHandler = async (req: Request, res: Response) => {
  if (!req.body) {
    return res.status(400).json({ message: 'Request body missing' });
  }

  const { phone, otp, name, email } = req.body;


  if (!phone || !otp) {
    return res.status(400).json({
      message: 'Phone & OTP required',
    });
  }

  const normalizedPhone = normalizePhone(phone);

  const otpResult = await verifyOtp(normalizedPhone, otp);

  if (!otpResult || otpResult.type !== 'success') {
    return res.status(400).json({
      message: 'Invalid or expired OTP',
    });
  }

  let user = await User.findOne({ phone: normalizedPhone });

  /**
   * SIGNUP CASE
   */
  if (!user) {
    if (!name || !email) {
      return res.status(400).json({
        message: 'Name & email required for signup',
      });
    }

    user = await User.create({
      name,
      email,
      phone: normalizedPhone,
      phoneVerified: true,
    });
  } else {
    /**
     * LOGIN CASE
     */
    if (!user.phoneVerified) {
      user.phoneVerified = true;
      await user.save();
    }
  }

  const token = jwt.sign(
    { id: user._id, role: user.role },
    appConfig.jwtSecret,
    { expiresIn: '7d' },
  );

  return res.json({
    message: 'Authentication successful',
    token,
    user: {
      id: user._id,
      name: user.name,
      phone: user.phone,
      role: user.role,
    },
  });
};
