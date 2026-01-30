import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import path from 'path';

import authRoutes from './routes/auth.routes';
import profileRoutes from './routes/user_routes/profile.routes';
import carRoutes from './routes/user_routes/car.routes';
import searchRoutes from './routes/user_routes/search.routes';
import blogRoutes from './routes/user_routes/blog.routes';
import adminRoutes from './routes/admin_routes/admin.routes';
import rtoRoutes from './routes/user_routes/rto.routes';
import brandRoutes from './routes/user_routes/brand.routes';
import enquiryRoutes from './routes/user_routes/enquiry.routes';
import comparisonRoutes from './routes/user_routes/comparison.routes';
import mediaRoutes from './routes/user_routes/media.routes';
import { createContactMessage } from "./controllers/user_controllers/contactUs.controller";
import loyaltyRoutes from "./routes/user_routes/loyalty.routes";
import loyaltyRoutesAdmin from "./routes/admin_routes/loyaltyCard.routes";
import bookingRoutes from './routes/user_routes/booking.routes';
import reviewRoutes from './routes/user_routes/review.routes';
import emiOfferRoutes from './routes/user_routes/emiOffer.routes';
import userEnquiryRoutes from './routes/user_routes/userEnquiry.routes';


dotenv.config();

const app = express();

app.use(cors());
app.use(express.json({ limit: '5mb' }));
app.use(express.urlencoded({ limit: '5mb', extended: true }));

//app.use(express.json());
app.use('/uploads', express.static(path.resolve(__dirname, '../uploads')));

app.use('/auth', authRoutes);
app.use('/profile', profileRoutes);
app.use('/cars', carRoutes);
app.use('/search', searchRoutes);
app.use('/blogs', blogRoutes);
app.use('/admin', adminRoutes);
app.use('/rto', rtoRoutes);
app.use('/brands', brandRoutes);
app.use('/user-enquiries', enquiryRoutes);
app.use('/comparisons', comparisonRoutes);
app.use('/media', mediaRoutes);
app.use("/contact-us", createContactMessage);
app.use('/docs', express.static(path.join(__dirname, '../public/docs')));
app.use("/loyalty", loyaltyRoutes);
app.use("/admin/loyalty", loyaltyRoutesAdmin);
app.use("/bookings", bookingRoutes);
app.use("/reviews", reviewRoutes);
app.use("/emi-offer", emiOfferRoutes);
app.use("/user-enquiries", userEnquiryRoutes);








export default app;

