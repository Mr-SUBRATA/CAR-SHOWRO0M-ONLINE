import { Response } from 'express';
import User from '../../models/user.model';
import Booking from '../../models/booking.model';
import { AuthenticatedRequest } from '../../middleware/auth.middleware';

export const getCurrentUser = async (
  req: AuthenticatedRequest,
  res: Response,
): Promise<Response> => {
  try {
    const userId = req.user?.id;
    if (!userId) {
      return res.status(401).json({ message: 'Unauthorized' });
    }

    const user = await User.findById(userId).select('-passwordHash').lean();
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    return res.json(user);
  } catch (error) {
    return res.status(500).json({ message: 'Failed to fetch user', error });
  }
};
export const getProfilePhoto = async (
  req: AuthenticatedRequest,
  res: Response,
): Promise<Response> => {
  try {
    const userId = req.user?.id;
    if (!userId) {
      return res.status(401).json({ message: 'Unauthorized' });
    }

    const user = await User.findById(userId)
      .select('profilePhoto profilePhotoMimeType')
      .lean();

    if (!user || !user.profilePhoto) {
      return res.status(404).json({ message: 'Profile photo not found' });
    }

    return res.json({
      imageBase64: `data:${user.profilePhotoMimeType};base64,${user.profilePhoto}`,
    });
  } catch {
    return res.status(500).json({
      message: 'Failed to fetch profile photo',
    });
  }
};

export const uploadProfilePicture = async (
  req: AuthenticatedRequest,
  res: Response,
): Promise<Response> => {
  try {
    const userId = req.user?.id;
    if (!userId) {
      return res.status(401).json({ message: 'Unauthorized' });
    }

    const { imageBase64, mimeType } = req.body;

    if (!imageBase64 || !mimeType) {
      return res.status(400).json({
        message: 'imageBase64 and mimeType are required',
      });
    }

    // ✅ allow only image mime types
    const allowedTypes = ['image/jpeg', 'image/png', 'image/webp'];
    if (!allowedTypes.includes(mimeType)) {
      return res.status(400).json({
        message: 'Only JPEG, PNG, WEBP images are allowed',
      });
    }

    // ✅ validate base64 format
    if (!imageBase64.startsWith('data:image')) {
      return res.status(400).json({
        message: 'Invalid base64 image format',
      });
    }

    // ✅ remove prefix for size calculation
    const base64Data = imageBase64.split(',')[1];
    if (!base64Data) {
      return res.status(400).json({
        message: 'Invalid base64 data',
      });
    }

    // ✅ correct size calculation
    const sizeInBytes = Buffer.from(base64Data, 'base64').length;
    const MAX_SIZE = 2 * 1024 * 1024; // 2MB

    if (sizeInBytes > MAX_SIZE) {
      return res.status(413).json({
        message: 'Image size must be less than 2MB',
      });
    }

    // ✅ store FULL base64 (important for frontend preview)
    const user = await User.findByIdAndUpdate(
      userId,
      {
        profilePhoto: imageBase64,
        profilePhotoMimeType: mimeType,
      },
      { new: true },
    );

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    return res.json({
      message: 'Profile picture uploaded successfully',
    });
  } catch (error) {
    console.error('UPLOAD PROFILE ERROR:', error);
    return res.status(500).json({
      message: 'Failed to upload profile picture',
    });
  }
};

export const updateProfile = async (
  req: AuthenticatedRequest,
  res: Response,
): Promise<Response> => {
  try {
    const userId = req.user?.id;
    if (!userId) {
      return res.status(401).json({ message: 'Unauthorized' });
    }

    const {
      name,
      phone,
      occupation,
      panNumber,
      aadharNumber,
      customerId,
      profilePhotoUrl,
      emailVerified,
      phoneVerified,
      panVerified,
      aadharVerified,
      currentAddress,
      permanentAddress,
      bankDetails,
      kyc,
    } = req.body;

    const updateData: Record<string, unknown> = {};

    if (name !== undefined) updateData.name = name;
    if (phone !== undefined) updateData.phone = phone;
    if (occupation !== undefined) updateData.occupation = occupation;
    if (panNumber !== undefined) updateData.panNumber = panNumber;
    if (aadharNumber !== undefined) updateData.aadharNumber = aadharNumber;
    if (customerId !== undefined) updateData.customerId = customerId;
    if (profilePhotoUrl !== undefined) updateData.profilePhotoUrl = profilePhotoUrl;

    if (emailVerified !== undefined) updateData.emailVerified = emailVerified;
    if (phoneVerified !== undefined) updateData.phoneVerified = phoneVerified;
    if (panVerified !== undefined) updateData.panVerified = panVerified;
    if (aadharVerified !== undefined) updateData.aadharVerified = aadharVerified;

    if (currentAddress !== undefined) updateData.currentAddress = currentAddress;
    if (permanentAddress !== undefined) updateData.permanentAddress = permanentAddress;
    if (bankDetails !== undefined) updateData.bankDetails = bankDetails;
    if (kyc !== undefined) updateData.kyc = kyc;

    const user = await User.findByIdAndUpdate(userId, updateData, {
      new: true,
      runValidators: true,
    }).select('-passwordHash');

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    return res.json(user);
  } catch (error) {
    return res.status(500).json({ message: 'Failed to update profile', error });
  }
};

export const getMyBookings = async (req: AuthenticatedRequest, res: Response): Promise<Response> => {
  try {
    const userId = req.user?.id;
    if (!userId) {
      return res.status(401).json({ message: 'Unauthorized' });
    }
    // Fetch all bookings, sorted by newest first
    const bookings = await Booking.find({ userId })
      .sort({ bookingDate: -1 })
      .lean();

    return res.status(200).json({
      bookings,
    });
  } catch (error: any) {
    console.error("Fetch all bookings error:", error);
    return res.status(500).json({
      success: false,
      message: "Failed to fetch bookings",
      error: error.message,
    });
  }
};

export const getMyCompareList = async (
  req: AuthenticatedRequest,
  res: Response,
): Promise<Response> => {
  try {
    const userId = req.user?.id;
    if (!userId) {
      return res.status(401).json({ message: 'Unauthorized' });
    }

    const user = await User.findById(userId).populate('compareList');
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    return res.json(user.compareList);
  } catch (error) {
    return res.status(500).json({ message: 'Failed to fetch compare list', error });
  }
};
