import { Router } from "express";
import { createBooking } from "../../controllers/user_controllers/booking.controller";
import { authMiddleware } from '../../middleware/auth.middleware';

const router = Router();

router.post("/create", authMiddleware, createBooking);

export default router;
