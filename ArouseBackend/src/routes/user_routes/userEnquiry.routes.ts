import { Router } from "express";
import { createEnquiry } from "../../controllers/user_controllers/userEnquiry.controller";

const router = Router();

/**
 * @route   POST /api/enquiries
 * @desc    Create car enquiry
 * @access  Public
 */
router.post("/", createEnquiry);

export default router;
