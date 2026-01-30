// import { Router } from 'express';
// import { register, login } from '../controllers/auth.controller';

// const router = Router();

// router.post('/register', register);
// router.post('/login', login);

// export default router;


import { Router } from 'express';
import { loginSendOtpHandler, verifyOtpHandler,signupSendOtpHandler } from '../controllers/user_controllers/auth.controller';
import { adminLoginHandler } from '../controllers/admin_controllers/auth.controller';

const router = Router();
router.post('/admin/login', adminLoginHandler);
router.post('/login/send-otp', loginSendOtpHandler);
router.post('/signup/send-otp', signupSendOtpHandler);
router.post('/verify-otp', verifyOtpHandler);


export default router;
