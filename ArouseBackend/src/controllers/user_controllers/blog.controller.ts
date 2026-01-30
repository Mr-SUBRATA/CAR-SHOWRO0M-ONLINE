import { Request, Response } from 'express';
import Blog from '../../models/blog.model';

export const getBlogs = async (req: Request, res: Response): Promise<Response> => {
  try {
    const { tag, limit = 10, page = 1 } = req.query;
    const pageSize = Number(limit) || 10;
    const currentPage = Number(page) || 1;
    const filter: Record<string, unknown> = {};

    if (tag) filter.tag = tag;

    const blogs = await Blog.find(filter)
      .limit(pageSize)
      .skip((currentPage - 1) * pageSize)
      .sort({ createdAt: -1 });

    return res.json(blogs);
  } catch (error) {
    return res.status(500).json({ message: 'Failed to fetch blogs', error });
  }
};

export const getBlogById = async (req: Request, res: Response): Promise<Response> => {
  try {
    const blog = await Blog.findById(req.params.id);
    if (!blog) {
      return res.status(404).json({ message: 'Blog not found' });
    }
    return res.json(blog);
  } catch (error) {
    return res.status(500).json({ message: 'Failed to fetch blog', error });
  }
};
