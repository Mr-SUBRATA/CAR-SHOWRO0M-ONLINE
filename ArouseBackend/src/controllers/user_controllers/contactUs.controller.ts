import { Request, Response } from "express";
import ContactUs from "../../models/contactUs.model";

export const createContactMessage = async (req: Request, res: Response) => {
  try {
    const { subject, message, name, email } = req.body;

    if (!subject || !message) {
      return res
        .status(400)
        .json({ message: "Subject & message are required" });
    }

    // Extract logged-in user details (assuming req.user exists)
    // const { name, email } = req.user;

    const newMessage = await ContactUs.create({
      name,
      email,
      subject,
      message,
      createdAt: new Date(),
    });

    return res.status(201).json({
      message: "Your message has been submitted successfully!",
      data: newMessage,
    });
  } catch (error) {
    return res.status(500).json({ message: "Internal server error", error });
  }
};

