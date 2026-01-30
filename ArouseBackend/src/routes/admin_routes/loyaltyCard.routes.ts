import { Router } from "express";
import {
  getAllLoyaltyCards,
  getUserLoyaltyCard,
  getLoyaltyPayments,
  approveLoyaltyPayment,
  forceRenewLoyalty,
} from "../../controllers/admin_controllers/loyaltyCard.controller";
import { adminOnly } from "../../middleware/auth.middleware";

const router = Router();

router.get("/cards", adminOnly, getAllLoyaltyCards);
router.get("/cards/:userId", adminOnly, getUserLoyaltyCard);

router.get("/payments", adminOnly, getLoyaltyPayments);
router.post("/payments/approve/:paymentId", adminOnly, approveLoyaltyPayment);

router.post("/force-renew/:userId", adminOnly, forceRenewLoyalty);

export default router;
