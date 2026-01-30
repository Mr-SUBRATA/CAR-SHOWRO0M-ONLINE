import { Response } from "express";
import { Types } from "mongoose";
import Booking from "../../models/booking.model";
import Vehicle from "../../models/vehicle.model";
import User from "../../models/user.model";
import { AuthenticatedRequest } from "../../middleware/auth.middleware";

export const createBooking = async (
  req: AuthenticatedRequest,
  res: Response
) => {
  try {
    const userId = req.user?.id;

    if (!userId) {
      return res.status(401).json({ message: "Unauthorized" });
    }

    const {
      bookingDate,
      vehicleId,
      bookingType,
      branch,
      amountPaid,
      currentAddress,
      permanentAddress,
      selectedRto,
      financeDetails,
      insuranceDetails,
      addons,
      accessories,
      dealerDetails
    } = req.body;

    /* ---------------- Validation ---------------- */

    if (!bookingDate || !vehicleId) {
      return res.status(400).json({
        message: "bookingDate and vehicleId are required",
      });
    }
    /* ---------------- Fetch User ---------------- */

    const user = await User.findById(userId).lean();

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    /* ---------------- Fetch Vehicle ---------------- */

    const vehicle = await Vehicle.findById(vehicleId).lean();

    if (!vehicle) {
      return res.status(404).json({ message: "Vehicle not found" });
    }

    /* ---------------- Booking ID ---------------- */

    const bookingId = "BK" + Date.now().toString().slice(-6);

    /* ---------------- Create Booking ---------------- */

    const booking = await Booking.create({
      bookingId,
      userId: new Types.ObjectId(userId),

      bookingDate: new Date(bookingDate),

      vehicle: {
        vehicleId: vehicle._id,
        name: vehicle.name,
        brand: vehicle.brand,
        fuelType: vehicle.fuelType,
        transmission: vehicle.transmission,
        price: vehicle.price,
        image: vehicle.images?.[0]?.data,
      },
      currentAddress,
      permanentAddress,
      selectedRto,
      financeDetails,
      insuranceDetails,
      addons,
      accessories,
      bookingType: bookingType || "Standard Market",
      branch,
      amountPaid: amountPaid || 0,
      dealerDetails
    });

    return res.status(201).json({
      message: "Booking created successfully",
    });
  } catch (error: any) {
    console.error("Create booking error:", error);
    return res.status(500).json({
      message: "Failed to create booking",
      error: error.message,
    });
  }
};
