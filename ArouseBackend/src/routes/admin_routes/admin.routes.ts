import { Router } from "express";

import {
  createCar,
  updateCar,
  deleteCar,
  upload,
  uploadCarImages,
  uploadCarMedia,
  handleCarImagesUpload,
  handleCarMediaUpload,
} from "../../controllers/admin_controllers/car.controller";

import {
  createBlog,
  updateBlog,
  deleteBlog,
} from "../../controllers/admin_controllers/blog.controller";

import {
  getAllBookings,
  updateBookingStatus,
} from "../../controllers/admin_controllers/booking.controller";

import {
  upsertRtoMaster,
  exportRtoCsv
} from "../../controllers/admin_controllers/rto.controller";

import {
  listAllEnquiries,
  updateEnquiryStatus,
  deliverEnquiry,
  markLostEnquiry,
  getUserPoints
} from "../../controllers/admin_controllers/enquery.controller";
import {
  authMiddleware,
  adminOnly,
} from "../../middleware/auth.middleware";

import { csvUpload, uploadRtoCsv } from "../../controllers/admin_controllers/rto.controller";

import { getInventory, deleteInventory } from '../../controllers/admin_controllers/inventory.controller';
import { recordSale, listSales } from '../../controllers/admin_controllers/sale.controller';

import { getAllContactMessages } from '../../controllers/admin_controllers/contactUs.controller';

import { getAllTestDriveBookings, updateTestDriveStatus } from '../../controllers/admin_controllers/testDrive.controller';
const router = Router();

/* -------------------------------------------------------------------------- */
/*                           AUTH MIDDLEWARE                                   */
/* -------------------------------------------------------------------------- */

router.use(authMiddleware);
router.use(adminOnly);

router.get('/dashboard', (req, res) => {
  res.json({ message: 'Welcome Admin' });
});


/* -------------------------------------------------------------------------- */
/*                               CARS                                          */
/* -------------------------------------------------------------------------- */
router.post("/cars", uploadCarImages, createCar);
router.patch("/cars/:id", uploadCarImages, updateCar);
router.delete("/cars/:id", deleteCar);

/* -------------------------------------------------------------------------- */
/*                               BLOGS                                         */
/* -------------------------------------------------------------------------- */
router.post("/blogs", upload.single("image"), createBlog);
router.patch("/blogs/:id", updateBlog);
router.delete("/blogs/:id", deleteBlog);

/* -------------------------------------------------------------------------- */
/*                              BOOKINGS                                       */
/* -------------------------------------------------------------------------- */
router.get("/bookings", getAllBookings);
router.patch("/bookings/:id", updateBookingStatus);

/* -------------------------------------------------------------------------- */
/*                              BOOK Test Drive                                   */
/* -------------------------------------------------------------------------- */
router.get("/test-drives", getAllTestDriveBookings);
router.patch("/test-drive/:id", updateTestDriveStatus);


/* -------------------------------------------------------------------------- */
/*                               RTO                                           */
/* -------------------------------------------------------------------------- */


router.get('/rto/export-csv', exportRtoCsv);
router.post("/rto/prices", upsertRtoMaster);
router.post('/rto/upload-csv', csvUpload.single('file'), uploadRtoCsv);


/* -------------------------------------------------------------------------- */
/*                              ENQUIRIES                                      */
/* -------------------------------------------------------------------------- */
router.get("/enquiries", listAllEnquiries);
router.patch("/enquiries/:id/status", updateEnquiryStatus);
router.post("/enquiries/:id/deliver", deliverEnquiry);
router.post("/enquiries/:id/lost", markLostEnquiry);
router.get("/points/:userId", getUserPoints);

/* -------------------------------------------------------------------------- */
/*                              ENQUIRIES                                      */
/* -------------------------------------------------------------------------- */

router.get("/contacts", getAllContactMessages);

/* -------------------------------------------------------------------------- */
/*                            MEDIA UPLOADS                                    */
/* -------------------------------------------------------------------------- */
router.post(
  "/uploads/car-images",
  uploadCarImages,
  handleCarImagesUpload
);

router.post(
  "/uploads/car-media",
  uploadCarMedia,
  handleCarMediaUpload
);
// Add inventory route

router.get(
  '/inventory',
  authMiddleware,
  adminOnly,
  getInventory
);

router.delete(
  '/inventory/:id',
  authMiddleware,
  adminOnly,
  deleteInventory
);

/* -------------------------------------------------------------------------- */
/*                                   SALES                                    */
/* -------------------------------------------------------------------------- */
router.post('/sales', recordSale);
router.get('/sales', listSales);


export default router;
