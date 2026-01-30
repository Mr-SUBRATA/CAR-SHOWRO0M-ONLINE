import { Request, Response } from 'express';
import { Types } from 'mongoose';
import Comparison from '../../models/comparison.model';
import Vehicle from '../../models/vehicle.model';
import { AuthenticatedRequest } from '../../middleware/auth.middleware';

const validateVehicleIds = async (
  vehicleIds: unknown,
): Promise<{ valid: true; ids: Types.ObjectId[] } | { valid: false; message: string }> => {
  if (!Array.isArray(vehicleIds)) return { valid: false, message: 'vehicleIds must be an array' };
  if (vehicleIds.length < 2 || vehicleIds.length > 3) {
    return { valid: false, message: 'vehicleIds must have between 2 and 3 ids' };
  }
  const ids = vehicleIds.map((id) => new Types.ObjectId(String(id)));
  const count = await Vehicle.countDocuments({ _id: { $in: ids } });
  if (count !== vehicleIds.length) {
    return { valid: false, message: 'One or more vehicleIds are invalid' };
  }
  return { valid: true, ids };
};

// Public: list only public comparisons (admin can mark sets public, users can create their own)
export const listComparisons = async (_req: Request, res: Response): Promise<Response> => {
  try {
    const comparisons = await Comparison.find({ isPublic: true })
      .sort({ updatedAt: -1 })
      .populate('vehicleIds');
    return res.json(comparisons);
  } catch (error) {
    return res.status(500).json({ message: 'Failed to fetch comparisons', error });
  }
};

// Public: fetch a single comparison only if public
export const getComparison = async (req: Request, res: Response): Promise<Response> => {
  try {
    const comparison = await Comparison.findOne({ _id: req.params.id, isPublic: true }).populate(
      'vehicleIds',
    );
    if (!comparison) {
      return res.status(404).json({ message: 'Comparison not found' });
    }
    return res.json(comparison);
  } catch (error) {
    return res.status(500).json({ message: 'Failed to fetch comparison', error });
  }
};

// User: create a shareable comparison set (defaults to public for sharing)
export const createComparison = async (req: AuthenticatedRequest, res: Response): Promise<Response> => {
  try {
    const { title = 'Comparison', vehicleIds, isPublic = true } = req.body;
    const validation = await validateVehicleIds(vehicleIds);
    if (!validation.valid) {
      return res.status(400).json({ message: validation.message });
    }

    const comparison = await Comparison.create({
      title,
      vehicleIds: validation.ids,
      isPublic: Boolean(isPublic),
      createdBy: req.user?.id,
    });

    const populated = await comparison.populate('vehicleIds');
    return res.status(201).json(populated);
  } catch (error) {
    return res.status(500).json({ message: 'Failed to create comparison', error });
  }
};

// User: list own comparisons (requires auth)
export const listMyComparisons = async (req: AuthenticatedRequest, res: Response): Promise<Response> => {
  try {
    if (!req.user?.id) {
      return res.status(401).json({ message: 'Unauthorized' });
    }
    const comparisons = await Comparison.find({ createdBy: req.user.id })
      .sort({ updatedAt: -1 })
      .populate('vehicleIds');
    return res.json(comparisons);
  } catch (error) {
    return res.status(500).json({ message: 'Failed to fetch comparisons', error });
  }
};
