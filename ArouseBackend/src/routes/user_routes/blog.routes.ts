import { Router } from 'express';
import { getBlogs, getBlogById } from '../../controllers/user_controllers/blog.controller';

const router = Router();

router.get('/', getBlogs);
router.get('/:id', getBlogById);

export default router;
