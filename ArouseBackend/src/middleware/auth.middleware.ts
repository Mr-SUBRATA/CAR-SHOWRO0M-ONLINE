
import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { appConfig } from '../config/env';

interface JwtPayload {
  id: string;
  role: 'user' | 'admin';
}

export interface AuthenticatedRequest extends Request {
  user?: JwtPayload;
}

export const authMiddleware = (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction,
) => {
  const token = req.headers.authorization?.split(' ')[1];

  if (!token) {
    return res.status(401).json({ message: 'Unauthorized' });
  }

  try {
    const decoded = jwt.verify(token, appConfig.jwtSecret) as JwtPayload;
    req.user = decoded;
    next();
  } catch {
    return res.status(401).json({ message: 'Invalid token' });
  }
};

export const adminOnly = (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction,
) => {
  if (req.user?.role !== 'admin') {
    return res.status(403).json({ message: 'Admin only access' });
  }
  next();
};
