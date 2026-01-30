import { Request, Response } from 'express';
import CarMedia from '../../models/carMedia.model';

export const serveCarImage = async (req: Request, res: Response): Promise<Response | void> => {
  try {
    const media = await CarMedia.findById(req.params.id);
    if (!media) {
      return res.status(404).json({ message: 'Not found' });
    }
    res.contentType(media.contentType);
    return res.send(media.data);
  } catch (error) {
    return res.status(500).json({ message: 'Failed to fetch media', error });
  }
};

export const serveCarMedia = async (req: Request, res: Response): Promise<Response | void> => {
  try {
    const media = await CarMedia.findById(req.params.id);
    if (!media) {
      return res.status(404).json({ message: 'Not found' });
    }
    res.contentType(media.contentType);
    return res.send(media.data);
  } catch (error) {
    return res.status(500).json({ message: 'Failed to fetch media', error });
  }
};
