import { Request, Response } from "express";
import EnquiryService from "../../services/enquery.service";
import { Types } from "mongoose";
import { AuthenticatedRequest } from "../../middleware/auth.middleware";
import { Parser } from "json2csv";

/**
 * Create a new enquiry (user)
 */

// export const createEnquiry = async (req: Request, res: Response) => {
//   try {
//     if (!req.body.userId) {
//       return res.status(400).json({ message: "userId is required" });
//     }

//     const userId = new Types.ObjectId(req.body.userId); // convert string -> ObjectId
//     const data = req.body;

//     const enquiry = await EnquiryService.createEnquiry(userId, data);
//     res.status(201).json(enquiry);
//   } catch (err: any) {
//     res.status(400).json({ message: err.message });
//   }
// };

export const createEnquiry = async (req: AuthenticatedRequest, res: Response) => {
  try {
    const {
      customerName,
      contactNumber,
      alternateNumber,
      preferredBrand,
      vehicleId,
    } = req.body;

    if (!req.user?.id) {
      return res.status(401).json({ message: "Unauthorized" });
    }

    if (!customerName || !contactNumber) {
      return res
        .status(400)
        .json({ message: "customerName and contactNumber are required" });
    }

    const userObjectId = new Types.ObjectId(req.user.id);
    //console.log(1);
    const enquiry = await EnquiryService.createEnquiry(userObjectId, {
      customerName,
      contactNumber,
      alternateNumber,
      preferredBrand,
      vehicleId,
    });
    //console.log(2);
    res.status(201).json(enquiry);
  } catch (err: any) {
    res.status(500).json({
      message: "Failed to create enquiry",
      error: err.message,
    });
  }
};

/**
 * Get status of a specific enquiry
 */
export const getEnquiryStatus = async (req: Request, res: Response) => {
  try {
    if (!req.params.id) {
      return res.status(400).json({ message: "enquiryId is required" });
    }

    const enquiryId = new Types.ObjectId(req.params.id);
    const enquiry = await EnquiryService.getEnquiryById(enquiryId);

    if (!enquiry) {
      return res.status(404).json({ message: "Enquiry not found" });
    }

    res.json({
      id: enquiry._id,
      status: enquiry.status,
      createdAt: enquiry.createdAt,
      updatedAt: enquiry.updatedAt,
      name: enquiry.customerName,
      contactNumber: enquiry.contactNumber,
      modelName: enquiry.modelName,
      preferredBrand: enquiry.preferredBrand,
    });
  } catch (err: any) {
    res.status(500).json({ message: err.message });
  }
};

/**
 * List enquiries for a user (filter by month/year optional)
 */
export const listMyEnquiries = async (req: Request, res: Response) => {
  try {
    const { contactNumber, month, year } = req.query;

    if (!contactNumber || typeof contactNumber !== "string") {
      return res.status(400).json({ message: "contactNumber is required" });
    }

    const enquiries = await EnquiryService.listUserEnquiries(
      contactNumber,
      month as string,
      year as string
    );

    res.json(enquiries);
  } catch (err: any) {
    res.status(500).json({ message: err.message });
  }
};


export const downloadMyEnquiries = async (req: AuthenticatedRequest, res: Response) => {

  try {
    const userId = req.user!.id;
    const { month, year } = req.query;

    if (!month || !year) {
      return res.status(400).json({ message: "month and year are required" });
    }

    const start = new Date(Number(year), Number(month) - 1, 1, 0, 0, 0);
    const end = new Date(Number(year), Number(month), 0, 23, 59, 59, 999);

    // console.log("Auth User ID:", userId);
    //console.log("Start:", start.toISOString());
    // console.log("End:", end.toISOString());

    const enquiries = await EnquiryService.downloadUserEnquiries(
      new Types.ObjectId(userId),
      start,
      end
    );

    // console.log("Enquiries Found:", enquiries.length);

    if (!enquiries.length) {
      return res.status(404).json({ message: "No enquiries available for this period" });
    }

    const fields = [
      "customerName",
      "contactNumber",
      "alternateNumber",
      "preferredBrand",
      "status",
      "createdAt",
    ];

    const parser = new Parser({ fields });
    const csv = parser.parse(enquiries);

    res.setHeader("Content-Type", "text/csv");
    res.setHeader("Content-Disposition", `attachment; filename=enquiries_${month}_${year}.csv`);
    res.send(csv);
  } catch (err: any) {
    res.status(500).json({ message: err.message });
  }
};
