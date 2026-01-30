import { Router } from 'express';
import {getFinalPrice ,getAllRtoCities, getAllRtoStates} from '../../controllers/user_controllers/rto.controller';

const router = Router();

// Admin-side: create or update RTO pricing for a vehicle/location.
//router.post('/prices', upsertRtoMaster);

// Public-side: fetch price for a vehicle at a given state/city.
router.get('/cars/:id/price', getFinalPrice);
router.get('/cities', getAllRtoCities);
router.get('/states', getAllRtoStates);



export default router;
