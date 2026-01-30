import { Request, Response } from 'express';
import Inventory from '../../models/inventory.model';

export const getInventory = async (req: Request, res: Response) => {
  const filter: any = { isActive: true };
  if (req.query.vehicle) {
    filter.vehicle = req.query.vehicle;
  } else if (req.query.id) {
    // Support filtering by ID if needed, though usually params
    filter._id = req.query.id;
  }

  const inventory = await Inventory.find(filter)
    .populate("vehicle", "model")
    .lean();

  return res.json({
    inventory: inventory.map((item: any) => ({
      id: item._id.toString(),
      modelName: item.modelName || 'Unknown Model',
      variant: item.variant || 'default',
      stock: item.stock,
      location: item.location,
    })),
  });
};

export const deleteInventory = async (req: Request, res: Response) => {
  const { id } = req.params;

  try {
    const result = await Inventory.findByIdAndDelete(id);
    if (!result) {
      return res.status(404).json({ message: 'Inventory not found' });
    }
    return res.json({ message: 'Inventory deleted successfully' });
  } catch (error: any) {
    return res.status(500).json({ message: error.message || 'Failed to delete inventory' });
  }
};
