import { Request, Response } from 'express';
import Brand from '../../models/brand.model';

export const listBrands = async (req: Request, res: Response): Promise<Response> => {
  try {
    const { featured, limit } = req.query;
    const filter: Record<string, unknown> = {};
    if (featured === 'true') {
      filter.isFeatured = true;
    }
    const query = Brand.find(filter).sort({ isFeatured: -1, priority: -1, name: 1 });
    if (limit) {
      const asNumber = Number(limit);
      if (!Number.isNaN(asNumber) && asNumber > 0) {
        query.limit(asNumber);
      }
    }
    const brands = await query;
    return res.json(brands);
  } catch (error) {
    return res.status(500).json({ message: 'Failed to fetch brands', error });
  }
};

export const getBrand = async (req: Request, res: Response): Promise<Response> => {
  try {
    const brand = await Brand.findById(req.params.id);
    if (!brand) {
      return res.status(404).json({ message: 'Brand not found' });
    }
    return res.json(brand);
  } catch (error) {
    return res.status(500).json({ message: 'Failed to fetch brand', error });
  }
};

