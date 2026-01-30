import { Router } from 'express';
import { authMiddleware } from '../../middleware/auth.middleware';
import {
  getCurrentUser,
  getMyBookings,
  getMyCompareList,
  updateProfile,
  uploadProfilePicture,getProfilePhoto
} from '../../controllers/user_controllers/profile.controller';

const router = Router();

router.get('/me', authMiddleware, getCurrentUser);
router.put('/me/update', authMiddleware, updateProfile);
router.get('/bookings', authMiddleware, getMyBookings);
router.get('/compare', authMiddleware, getMyCompareList);
router.get(
  '/photo',
  authMiddleware,
  getProfilePhoto,
);
router.post(
  '/upload-photo',
  authMiddleware,
  uploadProfilePicture,
);


export default router;
