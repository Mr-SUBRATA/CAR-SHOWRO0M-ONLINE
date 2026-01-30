import { Request, Response } from 'express';
import Booking from '../../models/bookTestDrive.model';

export const getAllTestDriveBookings = async (req: any, res: Response): Promise<Response> => {
  try {
    if (req.user?.role !== "admin") {
      return res.status(403).json({ message: "Access denied" });
    }

    const bookings = await Booking.find()
      .sort({ bookingDate: -1 })
      .lean();

    return res.json({
      bookings,
    });
  } catch (error) {
    return res.status(500).json({
      message: "Failed to fetch bookings",
      error,
    });
  }
};


export const updateTestDriveStatus = async (
  req: Request,
  res: Response
): Promise<Response> => {
  try {
    const { status } = req.body;
    const booking = await Booking.findByIdAndUpdate(
      req.params.id,
      { status },
      { new: true }
    );
    if (!booking) {
      return res.status(404).json({ message: "Booking not found" });
    }
    return res.json(booking);
  } catch (error) {
    return res
      .status(500)
      .json({ message: "Failed to update booking status", error });
  }
};
