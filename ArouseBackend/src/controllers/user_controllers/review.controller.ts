// src/controllers/review.controller.ts
import { Response } from "express";
import { AuthenticatedRequest } from "../../middleware/auth.middleware";

import { ReviewModel } from "../../models/review.model";
import User from "../../models/user.model";
import axios from "axios";

export const createReview = async (req: AuthenticatedRequest, res: Response) => {
    try {
        const userId = req.user?.id;

        if (!userId) {
            return res.status(401).json({ message: "Unauthorized" });
        }

        const { feedback, rating } = req.body;

        if (!feedback || !rating) {
            return res.status(400).json({ message: "Feedback and rating are required" });
        }

        if (rating < 1 || rating > 5) {
            return res.status(400).json({ message: "Rating must be between 1 and 5" });
        }

        // fetch user profile details
        const user = await User.findById(userId)
            .select("name occupation +profilePhoto profilePhotoMimeType")
            .lean();
        if (!user) {
            return res.status(404).json({ message: "User not found" });
        }



        const imageBase64 =
            user.profilePhoto && user.profilePhotoMimeType
                ? `data:${user.profilePhotoMimeType};base64,${user.profilePhoto}`
                : "";
        const review = await ReviewModel.create({
            username: user.name,
            occupation: user.occupation,
            image: imageBase64,

            feedback: feedback.trim(),
            rating,
        });

        return res.status(201).json(review);
    } catch (error) {
        return res.status(500).json({ message: "Error creating review", error });
    }
};

export const getReviews = async (req: AuthenticatedRequest, res: Response) => {
    try {
        const page = Number(req.query.page || 1);
        const limit = Number(req.query.limit || 10);

        const reviews = await ReviewModel.find()
            .sort({ createdAt: -1 })
            .skip((page - 1) * limit)
            .limit(limit);

        const total = await ReviewModel.countDocuments();

        return res.json({
            data: reviews,
            total,
            page,
            totalPages: Math.ceil(total / limit),
        });
    } catch (error) {
        return res.status(500).json({ message: "Error fetching reviews", error });
    }
};

export const getAverageRating = async (_req: AuthenticatedRequest, res: Response) => {
    try {
        const result = await ReviewModel.aggregate([
            {
                $group: {
                    _id: null,
                    averageRating: { $avg: "$rating" },
                    totalReviews: { $sum: 1 },
                },
            },
        ]);

        if (!result.length) {
            return res.json({ averageRating: 0, totalReviews: 0 });
        }

        return res.json({
            averageRating: Number(result[0].averageRating.toFixed(2)),
            totalReviews: result[0].totalReviews,
        });
    } catch (error) {
        return res
            .status(500)
            .json({ message: "Error calculating average rating", error });
    }
};
