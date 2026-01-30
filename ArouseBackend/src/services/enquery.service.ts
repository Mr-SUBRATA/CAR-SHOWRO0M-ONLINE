import Enquiry from "../models/enquiry.model";
import LoyaltyCard from "../models/loyalityCard.model";
import PointsService from "./points_service";
import { Types } from "mongoose";

class EnquiryService {
  async createEnquiry(userId: Types.ObjectId, data: any) {
    const card = await LoyaltyCard.findOne({ userId });
    if (!card || card.status !== "ACTIVE") {
      throw new Error("Renew your Loyalty Card to add enquiry");
    }

    const exists = await Enquiry.findOne({
      $or: [
        { contactNumber: data.contactNumber },
        { alternateNumber: data.contactNumber },
        ...(data.alternateNumber
          ? [
            { contactNumber: data.alternateNumber },
            { alternateNumber: data.alternateNumber },
          ]
          : []),
      ],
    });

    if (exists) throw new Error("This enquiry is already punched in ADMS");

    return Enquiry.create({
      ...data,
      userId,
      source: "LMC",
      status: "UNDER_PROCESS",
    });
  }

  async markLost(enquiryId: string | Types.ObjectId) {
    return Enquiry.findByIdAndUpdate(
      enquiryId,
      { status: "LOST", lostAt: new Date() },
      { new: true }
    );
  }
  async downloadUserEnquiries(
    userId: Types.ObjectId,
    start: Date,
    end: Date
  ) {
    return Enquiry.find({
      userId,
      createdAt: { $gte: start, $lt: end },
    }).lean();
  }

  async deliver(enquiryId: string | Types.ObjectId) {
    const enquiry = await Enquiry.findById(enquiryId);
    if (!enquiry) throw new Error("Enquiry not found");
    if (enquiry.pointsCredited) return enquiry;

    enquiry.status = "DELIVERED";
    enquiry.deliveredAt = new Date();
    enquiry.pointsCredited = true;
    await enquiry.save();

    if (enquiry.userId) {
      await PointsService.credit(enquiry.userId, 500, "LOYALTY", enquiry._id);
      await PointsService.calculateIndirect(enquiry.userId);
    }

    return enquiry;
  }

  async listAllEnquiries() {
    return Enquiry.find().sort({ createdAt: -1 });
  }

  async updateStatus(enquiryId: string | Types.ObjectId, status: "UNDER_PROCESS" | "BOOKED" | "DELIVERED" | "LOST") {
    return Enquiry.findByIdAndUpdate(enquiryId, { status }, { new: true });
  }


  async getEnquiryById(enquiryId: string | Types.ObjectId) {
    return Enquiry.findById(enquiryId);
  }

  async listUserEnquiries(contactNumber: string, month?: string, year?: string) {
    const filter: Record<string, any> = { contactNumber };

    if (month && year) {
      const m = Number(month);
      const y = Number(year);
      if (!isNaN(m) && !isNaN(y) && m >= 1 && m <= 12) {
        const start = new Date(y, m - 1, 1);
        const end = new Date(y, m, 1);
        filter.createdAt = { $gte: start, $lt: end };
      }
    }

    return Enquiry.find(filter).sort({ updatedAt: -1 });
  }
}

export default new EnquiryService();
