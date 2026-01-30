import { Router } from 'express';
import { listBrands, getBrand } from '../../controllers/user_controllers/brand.controller';

const router = Router();

router.get('/', listBrands);
router.get('/:id', getBrand);

export default router;
