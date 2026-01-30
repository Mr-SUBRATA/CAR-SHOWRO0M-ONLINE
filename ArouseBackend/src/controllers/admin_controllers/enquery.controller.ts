import { Request, Response } from "express";
import EnquiryService from "../../services/enquery.service";
import UserEnquiry from "../../models/userEnquiry.model";
import PointsService from "../../services/points_service";
import { Types } from "mongoose";

/**
 * Deliver an enquiry
 */
export const deliverEnquiry = async (req: Request, res: Response) => {
  try {
    const enquiryId = req.params.id;
    const enquiry = await EnquiryService.deliver(enquiryId);
    res.json(enquiry);
  } catch (err: any) {
    res.status(400).json({ message: err.message });
  }
};

/**
 * Mark an enquiry as LOST
 */
export const markLostEnquiry = async (req: Request, res: Response) => {
  try {
    const enquiryId = req.params.id;
    const enquiry = await EnquiryService.markLost(enquiryId);
    res.json(enquiry);
  } catch (err: any) {
    res.status(400).json({ message: err.message });
  }
};

/**
 * Get user points balance
 */
export const getUserPoints = async (req: Request, res: Response) => {
  try {
    if (!req.params.userId) {
      return res.status(400).json({ message: "userId is required" });
    }

    const userId = new Types.ObjectId(req.params.userId); // convert string -> ObjectId
    const balance = await PointsService.getBalance(userId);

    res.json({ userId: req.params.userId, balance }); // return original string for clarity
  } catch (err: any) {
    res.status(400).json({ message: err.message });
  }
};

/**
 * List all enquiries
 */
export const listAllEnquiries = async (_req: Request, res: Response) => {
  try {
    // Fetch User Enquiries (Website)
    const enquiries = await UserEnquiry.find().sort({ createdAt: -1 });

    // Map to Admin format
    const mapped = enquiries.map((enq) => ({
      _id: enq._id,
      name: `${enq.firstName} ${enq.lastName}`,
      contactNumber: enq.mobile,
      alternateNumber: enq.alternateMobile,
      preferredBrand: enq.preferredBrand,
      modelName: enq.preferredModel,
      status: enq.status === "new" ? "UNDER_PROCESS" : enq.status,
      createdAt: enq.createdAt,
      state: enq.state,
      city: enq.city,
    }));

    res.json(mapped);
  } catch (err: any) {
    res.status(500).json({ message: err.message });
  }
};

/**
 * Update enquiry status (admin-only)
 */
export const updateEnquiryStatus = async (req: Request, res: Response) => {
  try {
    const { status } = req.body;
    const allowed = ["UNDER_PROCESS", "BOOKED", "DELIVERED", "LOST"];
    if (!status || !allowed.includes(status)) {
      return res
        .status(400)
        .json({ message: `status must be one of: ${allowed.join(", ")}` });
    }

    const enquiryId = new Types.ObjectId(req.params.id); // convert string -> ObjectId

    // Update UserEnquiry
    const enquiry = await UserEnquiry.findByIdAndUpdate(
      enquiryId,
      { status },
      { new: true }
    );

    if (!enquiry) {
      return res.status(404).json({ message: "Enquiry not found" });
    }
    return res.json(enquiry);
  } catch (err: any) {
    return res
      .status(500)
      .json({ message: "Failed to update enquiry", error: err.message });
  }
};
