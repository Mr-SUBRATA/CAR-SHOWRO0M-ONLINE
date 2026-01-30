import { Types, startSession } from "mongoose";
import PointsLedger, { IPointsLedger } from "../models/pointLedger.model";
import Enquiry from "../models/enquiry.model";
import User from "../models/user.model";

class PointsService {
  async credit(
    userId: Types.ObjectId,
    points: number,
    type: "LOYALTY" | "INDIRECT" | "REFERRAL",
    ref?: Types.ObjectId
  ) {
    return PointsLedger.create({
      userId,
      points,
      type,
      referenceId: ref,
      month: new Date().toISOString().slice(0, 7),
    });
  }

  async debit(userId: Types.ObjectId, points: number, reason: string) {
    return PointsLedger.create({
      userId,
      points: -points,
      type: "DEBIT",
      description: reason,
      month: new Date().toISOString().slice(0, 7),
    });
  }

  async getBalance(userId: Types.ObjectId) {
    const result = await PointsLedger.aggregate([
      { $match: { userId, isReversed: { $ne: true } } },
      { $group: { _id: null, balance: { $sum: "$points" } } },
    ]);

    return result[0]?.balance || 0;
  }

  async calculateIndirect(userId: Types.ObjectId) {
    const deliveredCount = await Enquiry.countDocuments({ userId, status: "DELIVERED" });
    if (deliveredCount < 2) return;

    const referrals = await User.find({ referredBy: userId });

    // ✅ Explicitly type bulkPoints
    const bulkPoints: Partial<IPointsLedger>[] = [];
    const enquiryIdsToUpdate: Types.ObjectId[] = [];

    for (const ref of referrals) {
      const enquiries = await Enquiry.find({
        userId: ref._id,
        status: "DELIVERED",
        pointsCredited: { $ne: true },
      });

      for (const enquiry of enquiries) {
        bulkPoints.push({
          userId,
          points: 500,
          type: "INDIRECT",
          referenceId: enquiry._id,
          month: new Date().toISOString().slice(0, 7),
        });
        enquiryIdsToUpdate.push(enquiry._id);
      }
    }

    if (bulkPoints.length > 0) {
      const session = await startSession();
      await session.withTransaction(async () => {
        await PointsLedger.insertMany(bulkPoints, { session });
        await Enquiry.updateMany(
          { _id: { $in: enquiryIdsToUpdate } },
          { $set: { pointsCredited: true } },
          { session }
        );
      });
      session.endSession();
    }
  }
}

export default new PointsService();
