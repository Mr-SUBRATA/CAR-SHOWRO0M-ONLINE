import { Router } from 'express';
import { searchCars } from '../../controllers/user_controllers/search.controller';

const router = Router();

router.get('/cars', searchCars);

export default router;
