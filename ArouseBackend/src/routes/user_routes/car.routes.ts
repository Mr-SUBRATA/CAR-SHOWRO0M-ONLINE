import { Router } from 'express';
import {
  getCars,
  getModelsByBrand,
  getCarById,
  getSimilarCars,
  getVariantsWithPricing,
  calculateEmi,
  bookTestDrive,
  addToCompare,
  removeFromCompare,
  compareCarsInline,
} from '../../controllers/user_controllers/car.controller';
import { authMiddleware } from '../../middleware/auth.middleware';

const router = Router();

router.get('/', getCars);
router.get('/models', getModelsByBrand);
router.get('/compare', compareCarsInline);
router.get('/:id/variants', getVariantsWithPricing);
router.get('/:id', getCarById);
router.get('/:id/similar', getSimilarCars);
router.post('/emi', calculateEmi);
router.post('/book-test-drive', authMiddleware, bookTestDrive);
router.post('/:id/compare', addToCompare);
router.delete('/:id/compare', removeFromCompare);

export default router;
