import { Router } from 'express';
import { serveCarImage, serveCarMedia } from '../../controllers/user_controllers/media.controller';

const router = Router();

router.get('/car-images/:id', serveCarImage);
router.get('/car-media/:id', serveCarMedia);

export default router;
