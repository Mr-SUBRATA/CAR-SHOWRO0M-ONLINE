import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import User from '../../models/user.model';
import { appConfig } from '../../config/env';

export const adminLoginHandler = async (req: Request, res: Response) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: 'Email & password required' });
  }

  const admin = await User.findOne({ email, role: 'admin' }).select('+password');

  if (!admin || !admin.password) {
    return res.status(401).json({ message: 'Invalid credentials' });
  }

  const isMatch = await bcrypt.compare(password, admin.password);

  if (!isMatch) {
    return res.status(401).json({ message: 'Invalid credentials' });
  }

  const token = jwt.sign(
    { id: admin._id, role: admin.role },
    appConfig.jwtSecret,
    { expiresIn: '1d' },
  );

  return res.json({
    message: 'Admin login successful',
    token,
    admin: {
      id: admin._id,
      name: admin.name,
      email: admin.email,
      role: admin.role,
    },
  });
};
