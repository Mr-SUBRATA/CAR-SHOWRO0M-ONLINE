import { Request, Response } from "express";
import EmiOffer from "../../models/emiOffer.model";

export const createEmiOffer = async (req: Request, res: Response) => {
  try {
    const { name, phone, selectedDealer } = req.body;

    /// 🔐 BASIC VALIDATION
    if (!name || !phone) {
      return res.status(400).json({
        success: false,
        message: "Name, phone  are required",
      });
    }

    /// 📦 CREATE LEAD
    const emiOffer = await EmiOffer.create({
      name,
      phone,
      selectedDealer,
    });

    return res.status(201).json({
      message: "EMI offer request submitted successfully",
      data: emiOffer,
    });
  } catch (error) {
    console.error("EMI Offer Error:", error);
    return res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
};
