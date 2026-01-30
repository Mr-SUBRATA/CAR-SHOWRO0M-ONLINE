import { Response } from "express";
import { AuthenticatedRequest } from "../../middleware/auth.middleware";
import LoyaltyPayment from "../../models/loyaltyPayment.model";
import LoyaltyCard from "../../models/loyalityCard.model";


export const createFakeLoyaltyCard = async (req: AuthenticatedRequest, res: Response) => {
  try {
    const userId = req.user?.id;
    if (!userId) return res.status(401).json({ message: "Unauthorized" });

    // Check if card already exists
    const existing = await LoyaltyCard.findOne({ userId });
    if (existing) return res.status(400).json({ message: "Card already exists" });

    const now = new Date();
    const validTill = new Date();
    validTill.setFullYear(now.getFullYear() + 1);

    const card = await LoyaltyCard.create({
      userId,
      cardNumber: "DEV-LC-" + Date.now(),
      cvv7Hash: "FAKECVV",
      status: "ACTIVE",
      issueDate: now,
      validTill,
      yearlyIncome: 100000,
      autoRenew: false,
      isFake: true,
      activatedBy: "DEV",
    });

    res.status(201).json({
      message: "Fake loyalty card created (DEV ONLY)",
      card,
    });
  } catch (err: any) {
    res.status(500).json({ message: err.message });
  }
};

export const initiateLoyaltyPayment = async (
  req: AuthenticatedRequest,
  res: Response
) => {
  try {
    const userId = req.user!.id;

    const payment = await LoyaltyPayment.create({
      userId,
      amount: 449,
      method: "ONLINE",
      provider: "RAZORPAY",
      status: "PENDING",
    });

    res.status(201).json({
      message: "Payment initiated",
      paymentId: payment._id,
    });
  } catch (err: any) {
    res.status(500).json({ message: err.message });
  }
};
export const getMyLoyaltyCard = async (
  req: AuthenticatedRequest,
  res: Response
) => {
  try {
    const userId = req.user!.id;

    const card = await LoyaltyCard.findOne({ userId });

    if (!card) {
      return res.json({ status: "NOT_FOUND" });
    }

    if (card.validTill < new Date()) {
      return res.json({ status: "EXPIRED", card });
    }

    res.json({ status: "ACTIVE", card });
  } catch (err: any) {
    res.status(500).json({ message: err.message });
  }
};


export const verifyLoyaltyPayment = async (
  req: AuthenticatedRequest,
  res: Response
) => {
  try {
    const userId = req.user!.id;
    const { paymentId } = req.body;

    const payment = await LoyaltyPayment.findById(paymentId);
    if (!payment || payment.status !== "PENDING") {
      return res.status(400).json({ message: "Invalid payment" });
    }

    /**
     * 🔐 HERE:
     * - Verify Razorpay/Stripe signature
     * - For now assume SUCCESS
     */

    payment.status = "SUCCESS";
    payment.paidAt = new Date();
    await payment.save();

    // 🔁 Activate / Renew Loyalty Card
    const now = new Date();
    const validTill = new Date();
    validTill.setFullYear(now.getFullYear() + 1);

    let card = await LoyaltyCard.findOne({ userId });

    if (!card) {
      card = await LoyaltyCard.create({
        userId,
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