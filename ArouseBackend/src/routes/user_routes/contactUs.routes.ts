import { Router } from 'express';
import { createContactMessage } from "../../controllers/user_controllers/contactUs.controller";

const router = Router();

router.get("/", createContactMessage);
export default router;
