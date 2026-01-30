import { Router } from "express";
import { createEmiOffer } from "../../controllers/user_controllers/emiOffer.controller";

const router = Router();

router.post("/", createEmiOffer);

export default router;
