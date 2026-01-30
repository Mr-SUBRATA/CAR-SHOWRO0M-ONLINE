import { Request, Response } from 'express';
import Vehicle from '../../models/vehicle.model';

export const searchCars = async (req: Request, res: Response): Promise<Response> => {
  try {
    const { q, brand, type } = req.query;
    const filter: Record<string, unknown> = {};

    if (brand && typeof brand === 'string') filter.brand = { $regex: brand, $options: 'i' };
    if (type && typeof type === 'string') filter.type = { $regex: type, $options: 'i' };

    if (q) {
      const term = String(q);
      const regex = new RegExp(term, 'i');
      filter.$or = [
        { name: regex }, // model name
        { brand: regex }, // brand name
        { type: regex }, // vehicle type/category
        { 'variants.name': regex }, // variant names, if present
      ];
    }

    const cars = await Vehicle.find(filter).limit(50);
    return res.json(cars);
  } catch (error) {
    return res.status(500).json({ message: 'Search failed', error });
  }
};
