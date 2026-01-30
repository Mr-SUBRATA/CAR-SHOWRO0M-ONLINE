import { Request, Response } from "express";
import multer from "multer";
import Vehicle from "../../models/vehicle.model";
import CarMedia from "../../models/carMedia.model";
import Inventory from "../../models/inventory.model";


/* -------------------------------------------------------------------------- */
/*                               MULTER CONFIG                                */
/* -------------------------------------------------------------------------- */

const storage = multer.memoryStorage();

const carUpload = multer({
  storage,
  limits: { fileSize: 20 * 1024 * 1024 }, // 20MB
  fileFilter: (_req, file, cb) => {
    if (
      file.mimetype.startsWith("image/") ||
      file.mimetype === "application/pdf"
    ) {
      cb(null, true);
    } else {
      cb(new Error("Only image or PDF files allowed"));
    }
  },
});

export const upload = multer({ storage });
export const uploadCarImages = carUpload.any();
export const uploadCarMedia = carUpload.array("files", 10);

/* -------------------------------------------------------------------------- */
/*                              CREATE CAR                                    */
/* -------------------------------------------------------------------------- */

export const createCar = async (req: Request, res: Response): Promise<Response> => {
  try {
    const files = (req.files as Express.Multer.File[]) || [];

    const imageFiles = files.filter(f => f.fieldname === "images");
    const featureFiles = files.filter(f => f.fieldname === "featuresImages");
    const brochureFiles = files.filter(f => f.fieldname === "brochure");

    const payload = normalizeCarPayload(req.body);

    /* ------------------------------ MAIN IMAGES ----------------------------- */
    payload.images = imageFiles.map(file => ({
      filename: file.originalname,
      data: file.buffer,
      contentType: file.mimetype,
    }));

    /* ------------------------------- FEATURES -------------------------------- */
    if (payload.features && Array.isArray(payload.features)) {
      let fileIndex = 0;

      payload.features = payload.features.map((f: any) => {
        let image = f.image;

        if (f.hasFile && featureFiles[fileIndex]) {
          const file = featureFiles[fileIndex++];
          image = {
            filename: file.originalname,
            data: file.buffer,
            contentType: file.mimetype,
          };
        }

        if (!image?.data || !image?.contentType) return null;

        return {
          image,
          title: f.title ?? "",
          caption: f.caption ?? "",
        };
      }).filter(Boolean);
    }

    /* ------------------------------- BROCHURE -------------------------------- */
    if (brochureFiles.length > 0) {
      payload.brochureFiles = brochureFiles.map(file => ({
        filename: file.originalname,
        data: file.buffer,
        contentType: file.mimetype,
      }));
    }

    //const car = await Vehicle.create(payload);
    const car = await new Vehicle(payload).save();
    /* --------------------------- CREATE INVENTORY --------------------------- */

    let inventoryItems = [];

    if (req.body.inventory) {
      inventoryItems =
        typeof req.body.inventory === "string"
          ? JSON.parse(req.body.inventory)
          : req.body.inventory;
    }
    for (const item of inventoryItems) {
      if (!item.variant || item.stock === undefined) continue;

      const filter = {
        vehicle: car._id,
        modelName: item.modelName?.trim() || "default",
        variant: item.variant.trim().toLowerCase(),
        location: item.location || "Main Yard",
      };

      let update: any;

      if (item.overwrite === true) {
        update = {
          $set: {
            stock: Number(item.stock),
            location: item.location || "Main Yard",
            isActive: true,
          },
        };
      } else {
        update = {
          $inc: { stock: Number(item.stock) },
          $setOnInsert: {
            location: item.location || "Main Yard",
            isActive: true,
          },
        };
      }

      await Inventory.findOneAndUpdate(filter, update, {
        upsert: true,
        new: true,
      });

    }

    return res.status(201).json(car);

  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: "Failed to create car", error });
  }
};

/* -------------------------------------------------------------------------- */
/*                              UPDATE CAR                                    */
/* -------------------------------------------------------------------------- */

export const updateCar = async (req: Request, res: Response): Promise<Response> => {
  try {
    const files = (req.files as Express.Multer.File[]) || [];
    const payload = normalizeCarPayload(req.body);

    const imageFiles = files.filter(f => f.fieldname === "images");
    const featureFiles = files.filter(f => f.fieldname === "featuresImages");
    const brochureFiles = files.filter(f => f.fieldname === "brochure");

    const existing = await Vehicle.findById(req.params.id);
    if (!existing) return res.status(404).json({ message: "Car not found" });

    /* ------------------------------ MAIN IMAGES ----------------------------- */
    if (imageFiles.length > 0) {
      payload.images = imageFiles.map(file => ({
        filename: file.originalname,
        data: file.buffer,
        contentType: file.mimetype,
      }));
    } else {
      payload.images = existing.images;
    }

    /* ------------------------------- FEATURES -------------------------------- */
    const existingFeatures = existing.features || [];

    if (payload.features && Array.isArray(payload.features)) {
      let fileIndex = 0;

      payload.features = payload.features.map((f: any, index: number) => {
        let image = f.image || existingFeatures[index]?.image;

        if (f.hasFile && featureFiles[fileIndex]) {
          const file = featureFiles[fileIndex++];
          image = {
            filename: file.originalname,
            data: file.buffer,
            contentType: file.mimetype,
          };
        }

        if (!image?.data || !image?.contentType) return null;

        return {
          image,
          title: f.title ?? "",
          caption: f.caption ?? "",
        };
      }).filter(Boolean);
    } else {
      payload.features = existingFeatures;
    }

    /* ------------------------------- BROCHURE -------------------------------- */
    if (brochureFiles.length > 0) {
      payload.brochureFiles = brochureFiles.map(file => ({
        filename: file.originalname,
        data: file.buffer,
        contentType: file.mimetype,
      }));
    } else {
      payload.brochureFiles = existing.brochureFiles;
    }

    const car = await Vehicle.findByIdAndUpdate(
      req.params.id,
      payload,
      { new: true }
    );

    if (!car) return res.status(404).json({ message: "Car not found" });

    // update or create related inventory entry if stock/variant/model provided
    /* --------------------------- UPDATE INVENTORY --------------------------- */
    let inventoryItems = [];

    if (req.body.inventory) {
      inventoryItems =
        typeof req.body.inventory === "string"
          ? JSON.parse(req.body.inventory)
          : req.body.inventory;
    }

    for (const item of inventoryItems) {
      if (!item.variant || item.stock === undefined) continue;

      const filter = {
        vehicle: car._id,
        modelName: item.modelName?.trim() || "default",
        variant: item.variant.trim().toLowerCase(),
        location: item.location || "Main Yard",
      };

      let update: any;

      if (item.overwrite === true) {
        // ✅ FULL REPLACE stock
        update = {
          $set: {
            stock: Number(item.stock),
            location: item.location || "Main Yard",
            isActive: true,
          },
        };
      } else {
        // ✅ INCREMENT stock
        update = {
          $inc: {
            stock: Number(item.stock),
          },
          $setOnInsert: {
            location: item.location || "Main Yard",
            isActive: true,
            modelName: item.modelName?.trim() || "default",
          },
        };
      }

      await Inventory.findOneAndUpdate(filter, update, {
        upsert: true,
        new: true,
      });
    }



    return res.json(car);

  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: "Failed to update car", error });
  }
};

/* -------------------------------------------------------------------------- */
/*                              DELETE CAR                                    */
/* -------------------------------------------------------------------------- */

export const deleteCar = async (req: Request, res: Response): Promise<Response> => {
  try {
    const car = await Vehicle.findByIdAndDelete(req.params.id);
    if (!car) return res.status(404).json({ message: "Car not found" });

    // remove any inventory entries associated with this car
    try {
      await Inventory.deleteMany({ vehicle: car._id });
    } catch (invErr) {
      console.error('Failed to delete related inventory for car', car._id, invErr);
    }

    return res.json({ message: "Car deleted successfully" });
  } catch (error) {
    return res.status(500).json({ message: "Failed to delete car", error });
  }
};

/* -------------------------------------------------------------------------- */
/*                         NORMALIZE PAYLOAD                                   */
/* -------------------------------------------------------------------------- */

const normalizeCarPayload = (payload: Record<string, any>) => {
  const normalized: any = { ...payload };

  Object.keys(normalized).forEach((key) => {
    if (normalized[key] === undefined) delete normalized[key];
  });

  /* ----------------------- SPECIFICATIONS ----------------------- */
  if (normalized.specifications) {
    try {
      if (typeof normalized.specifications === "string") {
        normalized.specifications = JSON.parse(normalized.specifications);
      }

      normalized.specifications = {
        overview: Array.isArray(normalized.specifications.overview)
          ? normalized.specifications.overview
          : [],
        dimension: Array.isArray(normalized.specifications.dimension)
          ? normalized.specifications.dimension
          : [],
        wheels: Array.isArray(normalized.specifications.wheels)
          ? normalized.specifications.wheels
          : [],
        technology: Array.isArray(normalized.specifications.technology)
          ? normalized.specifications.technology
          : [],
        performance: Array.isArray(normalized.specifications.performance)
          ? normalized.specifications.performance
          : [],
      };
    } catch {
      normalized.specifications = {
        overview: [],
        dimension: [],
        wheels: [],
        technology: [],
        performance: [],
      };
    }
  }

  /* ----------------------- ARRAYS ----------------------- */
  const normalizeArray = (val: any) => {
    if (!val) return [];
    if (Array.isArray(val)) return val;
    try {
      return JSON.parse(val);
    } catch {
      return String(val)
        .split(",")
        .map((v) => v.trim())
        .filter(Boolean);
    }
  };

  if (normalized.colors) normalized.colors = normalizeArray(normalized.colors);
  if (normalized.safety) normalized.safety = normalizeArray(normalized.safety);

  /* ----------------------- FEATURES ----------------------- */
  if (normalized.features) {
    try {
      if (typeof normalized.features === "string") {
        normalized.features = JSON.parse(normalized.features);
      }
    } catch {
      normalized.features = [];
    }
  }

  /* ----------------------- VARIANTS ----------------------- */
  if (normalized.variants) {
    try {
      if (typeof normalized.variants === "string") {
        normalized.variants = JSON.parse(normalized.variants);
      }
    } catch {
      normalized.variants = [];
    }
  }

  return normalized;
};

export const handleCarImagesUpload = async (
  req: Request,
  res: Response
): Promise<Response> => {
  try {
    const files = (req.files as Express.Multer.File[]) || [];
    const host = `${req.protocol}://${req.get("host")}`;

    const docs = files.map((file) => ({
      filename: file.originalname,
      data: file.buffer,
      contentType: file.mimetype,
      kind: "image",
      carId: (req.body as { carId?: string }).carId,
    }));

    const saved = await CarMedia.insertMany(docs);

    const urls = saved.map(
      (d) => `${host}/media/car-images/${d._id.toString()}`
    );

    const carId = (req.body as { carId?: string }).carId;
    if (carId) {
      const embeddedImages = files.map((file) => ({
        filename: file.originalname,
        data: file.buffer,
        contentType: file.mimetype,
      }));

      await Vehicle.findByIdAndUpdate(carId, {
        $addToSet: { images: { $each: embeddedImages } },
      });
    }

    return res.json({ carId, urls });
  } catch (error) {
    return res.status(500).json({
      message: "Failed to upload car images",
      error,
    });
  }
};
export const handleCarMediaUpload = async (
  req: Request,
  res: Response
): Promise<Response> => {
  try {
    const files = (req.files as Express.Multer.File[]) || [];
    const host = `${req.protocol}://${req.get("host")}`;
    const { title, caption, carId } = req.body || {};

    if (carId) {
      const exists = await Vehicle.exists({ _id: carId });
      if (!exists) {
        return res.status(404).json({ message: "Car not found" });
      }
    }

    const docs = files.map((file) => ({
      filename: file.originalname,
      data: file.buffer,
      contentType: file.mimetype,
      kind: "media",
      carId,
      title,
      caption,
    }));

    const saved = await CarMedia.insertMany(docs);

    const urls = saved.map(
      (d) => `${host}/media/car-media/${d._id.toString()}`
    );

    return res.json({ urls, title, caption });
  } catch (error) {
    return res.status(500).json({
      message: "Failed to upload car media",
      error,
    });
  }
};


// import { Request, Response } from "express";
// import multer from "multer";
// import Vehicle from "../../models/vehicle.model";
// import CarMedia from "../../models/carMedia.model";
// import Inventory from "../../models/inventory.model";
// import { uploadToS3 } from "../../services/s3Upload.service";

// /* -------------------------------------------------------------------------- */
// /*                               MULTER CONFIG                                */
// /* -------------------------------------------------------------------------- */

// const storage = multer.memoryStorage();

// const carUpload = multer({
//   storage,
//   limits: { fileSize: 20 * 1024 * 1024 }, // 20MB
//   fileFilter: (_req, file, cb) => {
//     if (
//       file.mimetype.startsWith("image/") ||
//       file.mimetype === "application/pdf"
//     ) {
//       cb(null, true);
//     } else {
//       cb(new Error("Only image or PDF files allowed"));
//     }
//   },
// });

// export const upload = multer({ storage });
// export const uploadCarImages = carUpload.any();
// export const uploadCarMedia = carUpload.array("files", 10);

// /* -------------------------------------------------------------------------- */
// /*                              CREATE CAR                                    */
// /* -------------------------------------------------------------------------- */

// export const createCar = async (req: Request, res: Response): Promise<Response> => {
//   try {
//     const files = (req.files as Express.Multer.File[]) || [];

//     const imageFiles = files.filter(f => f.fieldname === "images");
//     const featureFiles = files.filter(f => f.fieldname === "featuresImages");
//     const brochureFiles = files.filter(f => f.fieldname === "brochure");

//     const payload = normalizeCarPayload(req.body);

//     /* ------------------------------ MAIN IMAGES ----------------------------- */
//     const imageUrls = await Promise.all(
//       imageFiles.map(file =>
//         uploadToS3({
//           buffer: file.buffer,
//           mimeType: file.mimetype,
//           folder: "cars/images",
//           fileName: file.originalname
//         })
//       )
//     );
//     payload.images = imageUrls.map(url => ({ url }));

//     /* ------------------------------- FEATURES -------------------------------- */
//     if (payload.features && Array.isArray(payload.features)) {
//       let fileIndex = 0;

//       const updatedFeatures = await Promise.all(
//         payload.features.map(async (f: any) => {
//           let image = f.image;

//           if (f.hasFile && featureFiles[fileIndex]) {
//             const file = featureFiles[fileIndex++];
//             const url = await uploadToS3({
//               buffer: file.buffer,
//               mimeType: file.mimetype,
//               folder: "cars/features",
//               fileName: file.originalname
//             });
//             image = { url };
//           }

//           if (!image?.url) return null;

//           return {
//             image,
//             title: f.title ?? "",
//             caption: f.caption ?? "",
//           };
//         })
//       );

//       payload.features = updatedFeatures.filter(Boolean);
//     }

//     /* ------------------------------- BROCHURE -------------------------------- */
//     if (brochureFiles.length > 0) {
//       const brochureUrls = await Promise.all(
//         brochureFiles.map(file =>
//           uploadToS3({
//             buffer: file.buffer,
//             mimeType: file.mimetype,
//             folder: "cars/brochures",
//             fileName: file.originalname
//           })
//         )
//       );
//       payload.brochureFiles = brochureUrls.map(url => ({ url }));
//     }

//     const car = await new Vehicle(payload).save();

//     /* --------------------------- CREATE INVENTORY --------------------------- */
//     let inventoryItems = [];
//     if (req.body.inventory) {
//       inventoryItems =
//         typeof req.body.inventory === "string"
//           ? JSON.parse(req.body.inventory)
//           : req.body.inventory;
//     }

//     for (const item of inventoryItems) {
//       if (!item.variant || item.stock === undefined) continue;

//       const filter = {
//         vehicle: car._id,
//         modelName: item.modelName?.trim() || "default",
//         variant: item.variant.trim().toLowerCase(),
//       };

//       const update = item.overwrite
//         ? {
//             $set: {
//               stock: Number(item.stock),
//               location: item.location || "Main Yard",
//               isActive: true,
//             },
//           }
//         : {
//             $inc: { stock: Number(item.stock) },
//             $setOnInsert: {
//               location: item.location || "Main Yard",
//               isActive: true,
//             },
//           };

//       await Inventory.findOneAndUpdate(filter, update, {
//         upsert: true,
//         new: true,
//       });
//     }

//     return res.status(201).json(car);

//   } catch (error) {
//     console.error(error);
//     return res.status(500).json({ message: "Failed to create car", error });
//   }
// };

// /* -------------------------------------------------------------------------- */
// /*                              UPDATE CAR                                    */
// /* -------------------------------------------------------------------------- */

// export const updateCar = async (req: Request, res: Response): Promise<Response> => {
//   try {
//     const files = (req.files as Express.Multer.File[]) || [];
//     const payload = normalizeCarPayload(req.body);

//     const imageFiles = files.filter(f => f.fieldname === "images");
//     const featureFiles = files.filter(f => f.fieldname === "featuresImages");
//     const brochureFiles = files.filter(f => f.fieldname === "brochure");

//     const existing = await Vehicle.findById(req.params.id);
//     if (!existing) return res.status(404).json({ message: "Car not found" });

//     /* ------------------------------ MAIN IMAGES ----------------------------- */
//     if (imageFiles.length > 0) {
//       const imageUrls = await Promise.all(
//         imageFiles.map(file =>
//           uploadToS3({
//             buffer: file.buffer,
//             mimeType: file.mimetype,
//             folder: "cars/images",
//             fileName: file.originalname
//           })
//         )
//       );
//       payload.images = imageUrls.map(url => ({ url }));
//     } else {
//       payload.images = existing.images;
//     }

//     /* ------------------------------- FEATURES -------------------------------- */
//     const existingFeatures = existing.features || [];
//     if (payload.features && Array.isArray(payload.features)) {
//       let fileIndex = 0;

//       const updatedFeatures = await Promise.all(
//         payload.features.map(async (f: any, index: number) => {
//           let image = f.image || existingFeatures[index]?.image;

//           if (f.hasFile && featureFiles[fileIndex]) {
//             const file = featureFiles[fileIndex++];
//             const url = await uploadToS3({
//               buffer: file.buffer,
//               mimeType: file.mimetype,
//               folder: "cars/features",
//               fileName: file.originalname
//             });
//             image = { url };
//           }

//           if (!image?.url) return null;

//           return {
//             image,
//             title: f.title ?? "",
//             caption: f.caption ?? "",
//           };
//         })
//       );

//       payload.features = updatedFeatures.filter(Boolean);
//     } else {
//       payload.features = existingFeatures;
//     }

//     /* ------------------------------- BROCHURE -------------------------------- */
//     if (brochureFiles.length > 0) {
//       const brochureUrls = await Promise.all(
//         brochureFiles.map(file =>
//           uploadToS3({
//             buffer: file.buffer,
//             mimeType: file.mimetype,
//             folder: "cars/brochures",
//             fileName: file.originalname
//           })
//         )
//       );
//       payload.brochureFiles = brochureUrls.map(url => ({ url }));
//     } else {
//       payload.brochureFiles = existing.brochureFiles;
//     }

//     const car = await Vehicle.findByIdAndUpdate(req.params.id, payload, { new: true });
//     if (!car) return res.status(404).json({ message: "Car not found" });

//     /* --------------------------- UPDATE INVENTORY --------------------------- */
//     let inventoryItems = [];
//     if (req.body.inventory) {
//       inventoryItems =
//         typeof req.body.inventory === "string"
//           ? JSON.parse(req.body.inventory)
//           : req.body.inventory;
//     }

//     for (const item of inventoryItems) {
//       if (!item.variant || item.stock === undefined) continue;

//       const filter = {
//         vehicle: car._id,
//         modelName: item.modelName?.trim() || "default",
//         variant: item.variant.trim().toLowerCase(),
//       };

//       const update = item.overwrite
//         ? {
//             $set: {
//               stock: Number(item.stock),
//               location: item.location || "Main Yard",
//               isActive: true,
//             },
//           }
//         : {
//             $inc: { stock: Number(item.stock) },
//             $setOnInsert: {
//               location: item.location || "Main Yard",
//               isActive: true,
//               modelName: item.modelName?.trim() || "default",
//             },
//           };

//       await Inventory.findOneAndUpdate(filter, update, { upsert: true, new: true });
//     }

//     return res.json(car);

//   } catch (error) {
//     console.error(error);
//     return res.status(500).json({ message: "Failed to update car", error });
//   }
// };

// /* -------------------------------------------------------------------------- */
// /*                              DELETE CAR                                    */
// /* -------------------------------------------------------------------------- */

// export const deleteCar = async (req: Request, res: Response): Promise<Response> => {
//   try {
//     const car = await Vehicle.findByIdAndDelete(req.params.id);
//     if (!car) return res.status(404).json({ message: "Car not found" });

//     try {
//       await Inventory.deleteMany({ vehicle: car._id });
//     } catch (invErr) {
//       console.error('Failed to delete related inventory for car', car._id, invErr);
//     }

//     return res.json({ message: "Car deleted successfully" });
//   } catch (error) {
//     return res.status(500).json({ message: "Failed to delete car", error });
//   }
// };

// /* -------------------------------------------------------------------------- */
// /*                         NORMALIZE PAYLOAD                                   */
// /* -------------------------------------------------------------------------- */

// const normalizeCarPayload = (payload: Record<string, any>) => {
//   const normalized: any = { ...payload };
//   Object.keys(normalized).forEach((key) => {
//     if (normalized[key] === undefined) delete normalized[key];
//   });

//   const normalizeArray = (val: any) => {
//     if (!val) return [];
//     if (Array.isArray(val)) return val;
//     try {
//       return JSON.parse(val);
//     } catch {
//       return String(val).split(",").map(v => v.trim()).filter(Boolean);
//     }
//   };

//   if (normalized.specifications) {
//     try {
//       if (typeof normalized.specifications === "string") normalized.specifications = JSON.parse(normalized.specifications);
//       normalized.specifications = {
//         overview: Array.isArray(normalized.specifications.overview) ? normalized.specifications.overview : [],
//         dimension: Array.isArray(normalized.specifications.dimension) ? normalized.specifications.dimension : [],
//         wheels: Array.isArray(normalized.specifications.wheels) ? normalized.specifications.wheels : [],
//         technology: Array.isArray(normalized.specifications.technology) ? normalized.specifications.technology : [],
//         performance: Array.isArray(normalized.specifications.performance) ? normalized.specifications.performance : [],
//       };
//     } catch {
//       normalized.specifications = { overview: [], dimension: [], wheels: [], technology: [], performance: [] };
//     }
//   }

//   if (normalized.colors) normalized.colors = normalizeArray(normalized.colors);
//   if (normalized.safety) normalized.safety = normalizeArray(normalized.safety);

//   if (normalized.features) {
//     try {
//       if (typeof normalized.features === "string") normalized.features = JSON.parse(normalized.features);
//     } catch { normalized.features = []; }
//   }

//   if (normalized.variants) {
//     try {
//       if (typeof normalized.variants === "string") normalized.variants = JSON.parse(normalized.variants);
//     } catch { normalized.variants = []; }
//   }

//   return normalized;
// };
