import { Router } from "express";
import {
  createEnquiry,
  downloadMyEnquiries,
  getEnquiryStatus,
  listMyEnquiries,
} from "../../controllers/user_controllers/enquiry.controller";
import { getUserPoints } from "../../controllers/admin_controllers/enquery.controller"; // reuse points controller
import { authMiddleware } from "../../middleware/auth.middleware";

const router = Router();

router.post("/create-enquiry",authMiddleware, createEnquiry);
router.get("/:id",authMiddleware, getEnquiryStatus);
router.get("/allenquiries",authMiddleware, listMyEnquiries);
router.get("/points/:userId",authMiddleware, getUserPoints);
router.get(
  "/my/download",
  authMiddleware,
  downloadMyEnquiries
);


export default router;
