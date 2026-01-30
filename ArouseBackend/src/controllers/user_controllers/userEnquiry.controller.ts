import { Request, Response } from "express";
import userEnquiry from "../../models/userEnquiry.model";

export const createEnquiry = async (
  req: Request,
  res: Response
): Promise<Response> => {
  try {
    const {
      firstName,
      lastName,
      mobile,
      alternateMobile,
      email,
      currentAddress,
      state,
      city,
      pinCode,
      preferredBrand,
      preferredModel,
      remark,
    } = req.body;

    if (!firstName || !lastName || !mobile) {
      return res.status(400).json({
        success: false,
        message: "First name, last name and mobile are required",
      });
    }

    const enquiry = await userEnquiry.create({
      firstName,
      lastName,
      mobile,
      alternateMobile,
      email,
      currentAddress,
      state,
      city,
      pinCode,
      preferredBrand,
      preferredModel,
      remark,
    });

    return res.status(201).json({
      success: true,
      message: "Enquiry submitted successfully",
      enquiry,
    });
  } catch (error) {
    console.error("Create enquiry error:", error);
    return res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
};
