import { Router } from 'express';
import { authMiddleware } from '../../middleware/auth.middleware';
import {
  getComparison,
  listComparisons,
  listMyComparisons,
  createComparison,
} from '../../controllers/user_controllers/comparison.controller';

const router = Router();

// User: create and list own comparisons (for share/save)
router.post('/', authMiddleware, createComparison);
router.get('/mine/all', authMiddleware, listMyComparisons);

// Public: list and view only public comparisons
router.get('/', listComparisons);
router.get('/:id', getComparison);

export default router;
