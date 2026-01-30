import { Request, Response } from "express";
import ContactUs from "../../models/contactUs.model";

export const getAllContactMessages = async (req: Request, res: Response) => {
  try {
    const messages = await ContactUs.find().sort({ createdAt: -1 });

    return res.status(200).json({
      message: "Contact messages fetched successfully",
      data: messages,
    });
  } catch (error) {
    return res.status(500).json({ message: "Internal server error", error });
  }
};
