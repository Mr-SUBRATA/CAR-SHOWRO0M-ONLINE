// src/routes/review.routes.ts
import express from "express";
import {
  createReview,
  getReviews,
  getAverageRating,
} from "../../controllers/user_controllers/review.controller";
import { authMiddleware } from '../../middleware/auth.middleware';

const router = express.Router();

router.post("/submit",authMiddleware, createReview);                 // POST /reviews
router.get("/fetch",authMiddleware, getReviews);                    // GET  /reviews
router.get("/average-rating",authMiddleware, getAverageRating); // GET /reviews/average-rating

export default router;
