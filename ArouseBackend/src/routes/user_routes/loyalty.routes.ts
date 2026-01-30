import { Router } from "express";
import {
    getMyLoyaltyCard,
    initiateLoyaltyPayment,
    verifyLoyaltyPayment,createFakeLoyaltyCard
} from "../../controllers/user_controllers/loyaltyCard.controller";


import { authMiddleware } from "../../middleware/auth.middleware";

const router = Router();

/* ========================= USER ROUTES ========================= */


// 🪪 Get my loyalty card
router.get("/me", authMiddleware, getMyLoyaltyCard);

// 💳 Create payment order (₹449)
router.post("/payment/initiate", authMiddleware, initiateLoyaltyPayment);

// ✅ Verify payment & renew loyalty
router.post("/payment/verify", authMiddleware, verifyLoyaltyPayment);

// 🃏 Create fake loyalty card (DEV ONLY) 
router.post("/fake-create", authMiddleware, createFakeLoyaltyCard);


export default router;
