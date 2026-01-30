import { Request, Response } from 'express';
import Blog from '../../models/blog.model';

export const createBlog = async (
  req: Request,
  res: Response
): Promise<Response> => {
  try {
    const { title, slug, tag, excerpt, content, author } = req.body;

    let imageData = undefined;
    if (req.file) {
      imageData = {
        data: req.file.buffer,
        contentType: req.file.mimetype,
      };
    }

    const blog = await Blog.create({
      title,
      slug,
      tag,
      excerpt,
      content,
      author,
      image: imageData,
    });

    return res.status(201).json(blog);
  } catch (error) {
    return res.status(500).json({ message: "Failed to create blog", error });
  }
};

export const updateBlog = async (
  req: Request,
  res: Response
): Promise<Response> => {
  try {
    const blog = await Blog.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
    });
    if (!blog) {
      return res.status(404).json({ message: "Blog not found" });
    }
    return res.json(blog);
  } catch (error) {
    return res.status(500).json({ message: "Failed to update blog", error });
  }
};

export const deleteBlog = async (
  req: Request,
  res: Response
): Promise<Response> => {
  try {
    const blog = await Blog.findByIdAndDelete(req.params.id);
    if (!blog) {
      return res.status(404).json({ message: "Blog not found" });
    }
    return res.json({ message: "Blog deleted" });
  } catch (error) {
    return res.status(500).json({ message: "Failed to delete blog", error });
  }
};



// import { Request, Response } from 'express';
// import Blog from '../../models/blog.model';
// import { uploadToS3 } from '../../services/s3Upload.service';

// /* -------------------------------------------------------------------------- */
// /*                              CREATE BLOG                                    */
// /* -------------------------------------------------------------------------- */

// export const createBlog = async (
//   req: Request,
//   res: Response
// ): Promise<Response> => {
//   try {
//     const { title, slug, tag, excerpt, content, author } = req.body;

//     let imageData = undefined;

//     // Upload image to S3 if file exists
//     if (req.file) {
//       const imageUrl = await uploadToS3({
//         buffer: req.file.buffer,
//         mimeType: req.file.mimetype,
//         folder: 'blogs/images', // S3 folder
//         fileName: req.file.originalname, // optional
//       });

//       imageData = {
//         url: imageUrl,
//         contentType: req.file.mimetype,
//       };
//     }

//     const blog = await Blog.create({
//       title,
//       slug,
//       tag,
//       excerpt,
//       content,
//       author,
//       image: imageData,
//     });

//     return res.status(201).json(blog);
//   } catch (error) {
//     console.error(error);
//     return res.status(500).json({ message: "Failed to create blog", error });
//   }
// };

// /* -------------------------------------------------------------------------- */
// /*                              UPDATE BLOG                                    */
// /* -------------------------------------------------------------------------- */

// export const updateBlog = async (
//   req: Request,
//   res: Response
// ): Promise<Response> => {
//   try {
//     const { title, slug, tag, excerpt, content, author } = req.body;

//     const updateData: any = {
//       title,
//       slug,
//       tag,
//       excerpt,
//       content,
//       author,
//     };

//     // Handle image update if a new file is uploaded
//     if (req.file) {
//       const imageUrl = await uploadToS3({
//         buffer: req.file.buffer,
//         mimeType: req.file.mimetype,
//         folder: 'blogs/images',
//         fileName: req.file.originalname,
//       });

//       updateData.image = {
//         url: imageUrl,
//         contentType: req.file.mimetype,
//       };
//     }

//     const blog = await Blog.findByIdAndUpdate(req.params.id, updateData, {
//       new: true,
//     });

//     if (!blog) {
//       return res.status(404).json({ message: "Blog not found" });
//     }

//     return res.json(blog);
//   } catch (error) {
//     console.error(error);
//     return res.status(500).json({ message: "Failed to update blog", error });
//   }
// };

// /* -------------------------------------------------------------------------- */
// /*                              DELETE BLOG                                    */
// /* -------------------------------------------------------------------------- */

// export const deleteBlog = async (
//   req: Request,
//   res: Response
// ): Promise<Response> => {
//   try {
//     const blog = await Blog.findByIdAndDelete(req.params.id);
//     if (!blog) {
//       return res.status(404).json({ message: "Blog not found" });
//     }
//     return res.json({ message: "Blog deleted" });
//   } catch (error) {
//     console.error(error);
//     return res.status(500).json({ message: "Failed to delete blog", error });
//   }
// };
