import { Request, Response } from "express";
import Sale from "../../models/sale.model";
import Inventory from "../../models/inventory.model";
import Vehicle from "../../models/vehicle.model";

export const recordSale = async (req: Request, res: Response): Promise<Response> => {
  try {
    const { vehicleId, variant, customerName, phone, address, source, quantity } = req.body;
    const qty = Number(quantity) || 1;

    if (!vehicleId) return res.status(400).json({ message: "vehicleId is required" });

    // 🔹 Fetch vehicle
    const vehicle = await Vehicle.findById(vehicleId).lean();
    if (!vehicle) {
      return res.status(404).json({ message: "Vehicle not found" });
    }

    const vehicleName =
      vehicle.name ||
      `${vehicle.brand || ""} ${vehicle.model || ""}`.trim() ||
      vehicle.model ||
      "Unknown Vehicle";
    // Atomic decrement: ensure stock >= qty
    const inventory = await Inventory.findOneAndUpdate(
      { vehicle: vehicleId, variant: variant || "default", stock: { $gte: qty } },
      { $inc: { stock: -qty } },
      { new: true }
    );

    if (!inventory) {
      return res.status(400).json({ message: "Out of stock or insufficient stock" });
    }

    const sale = await new Sale({
      vehicle: vehicleId,
      vehicleName,
      variant: variant || "default",
      customerName,
      phone,
      address,
      source,
      quantity: qty,
    }).save();

    return res.status(201).json({ sale, inventory, vehicle });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: "Failed to record sale", error });
  }
};

export const listSales = async (_req: Request, res: Response): Promise<Response> => {
  try {
    const sales = await Sale.find()
      .populate("vehicle", "name")
      .populate("customerName", "name phone email")
      .sort({ createdAt: -1 })
      .lean();
    const formatted = sales.map((s: any) => ({
      id: s._id.toString(),
      date: s.createdAt,
      carName: s.vehicleName,
      customerName: s.customerName,
      phone: s.phone || null,
      address: s.address || null,
      source: s.source || null,
      variant: s.variant,
      quantity: s.quantity,
    }));

    return res.json({ sales: formatted });
  } catch (error) {
    return res.status(500).json({ message: "Failed to fetch sales", error });
  }
};
