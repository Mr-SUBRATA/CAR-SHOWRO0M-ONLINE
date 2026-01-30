import { Request, Response } from "express";
import LoyaltyCard from "../../models/loyalityCard.model";
import LoyaltyPayment from "../../models/loyaltyPayment.model";
import { Types } from "mongoose";
/**
 * 📋 Get all loyalty cards (Admin)
 */
export const getAllLoyaltyCards = async (_req: Request, res: Response) => {
  try {
    const cards = await LoyaltyCard.find()
      .populate("userId", "name phone email")
      .sort({ updatedAt: -1 });

    res.json(cards);
  } catch (err: any) {
    res.status(500).json({ message: err.message });
  }
};

/**
 * 👤 Get a single user's loyalty card
 */
export const getUserLoyaltyCard = async (req: Request, res: Response) => {
  try {
    const { userId } = req.params;

    if (!Types.ObjectId.isValid(userId)) {
      return res.status(400).json({ message: "Invalid userId" });
    }

    const card = await LoyaltyCard.findOne({ userId });

    if (!card) {
      return res.status(404).json({ message: "Loyalty card not found" });
    }

    res.json(card);
  } catch (err: any) {
    res.status(500).json({ message: err.message });
  }
};

/**
 * 💰 View loyalty payments (Admin)
 */
export const getLoyaltyPayments = async (_req: Request, res: Response) => {
  try {
    const payments = await LoyaltyPayment.find()
      .populate("userId", "name phone email")
      .sort({ createdAt: -1 });

    res.json(payments);
  } catch (err: any) {
    res.status(500).json({ message: err.message });
  }
};

/**
 * ⚠ Force renew loyalty card (Admin only)
 */
export const forceRenewLoyalty = async (req: Request, res: Response) => {
  try {
    const { userId } = req.params;

    if (!Types.ObjectId.isValid(userId)) {
      return res.status(400).json({ message: "Invalid userId" });
    }

    const now = new Date();
    const validTill = new Date();
    validTill.setFullYear(now.getFullYear() + 1);

    const card = await LoyaltyCard.findOneAndUpdate(
      { userId },
      {
        status: "ACTIVE",
        issueDate: now,
        validTill,
      },
      { upsert: true, new: true }
    );

    res.json({
      message: "Loyalty card renewed successfully (Admin override)",
      card,
    });
  } catch (err: any) {
    res.status(500).json({ message: err.message });
  }
};

export const approveLoyaltyPayment = async (
  req: Request,
  res: Response
) => {
  try {
    const { paymentId } = req.params;

    const payment = await LoyaltyPayment.findById(paymentId);
    if (!payment || payment.status !== "PENDING") {
      return res.status(400).json({ message: "Invalid payment" });
    }

    payment.status = "SUCCESS";
    payment.paidAt = new Date();
    await payment.save();

    const now = new Date();
    const validTill = new Date();
    validTill.setFullYear(now.getFullYear() + 1);

    let card = await LoyaltyCard.findOne({ userId: payment.userId });

    if (!card) {
      card = await LoyaltyCard.create({
        userId: payment.userId,
        cardNumber: "LC-" + Date.now(),
        status: "ACTIVE",
        issueDate: now,
        validTill,
      });
    } else {
      card.status = "ACTIVE";
      card.issueDate = now;
      card.validTill = validTill;
      await card.save();
    }

    res.json({
      message: "Loyalty activated successfully",
      card,
    });
  } catch (err: any) {
    res.status(500).json({ message: err.message });
  }
};
