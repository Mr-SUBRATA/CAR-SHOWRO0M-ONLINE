import { Request, Response } from 'express';
import Vehicle from '../../models/vehicle.model';
import Booking from '../../models/bookTestDrive.model';
import User from '../../models/user.model';
import { AuthenticatedRequest } from '../../middleware/auth.middleware';
import RtoMaster from '../../models/rtoPrice.model';

const ALLOWED_TEST_DRIVE_PINCODES = (process.env.TEST_DRIVE_PINCODES || '')
  .split(',')
  .map((p) => p.trim())
  .filter(Boolean);

// Fallback guest compare list when no authenticated user is present.
const guestCompareList = new Set<string>();

export const getCars = async (req: Request, res: Response): Promise<Response> => {
  try {
    const { brand, type, featured, luxury, model } = req.query;
    const filter: Record<string, unknown> = {};

    if (brand) filter.brand = brand;
    if (type) filter.type = type;
    if (featured) filter.isFeatured = featured === 'true';
    if (luxury) filter.isLuxury = luxury === 'true';
    if (model) filter.name = model;

    const cars = await Vehicle.find(filter);
    return res.json(cars);
  } catch (error) {
    return res.status(500).json({ message: 'Failed to fetch cars', error });
  }
};

// Fetch model list for a given brand (for test-drive selection flows)
export const getModelsByBrand = async (req: Request, res: Response): Promise<Response> => {
  try {
    const { brand, model } = req.query;
    if (!brand || typeof brand !== 'string') {
      return res.status(400).json({ message: 'brand is required' });
    }

    const filter: Record<string, unknown> = { brand };
    if (model && typeof model === 'string') {
      filter.name = model;
    }

    const models = await Vehicle.find(filter)
      .select(['-_id', 'name', 'brand', 'type', 'images', 'price'])
      .sort({ name: 1 });

    return res.json(models);
  } catch (error) {
    return res.status(500).json({ message: 'Failed to fetch models', error });
  }
};

export const getCarById = async (req: Request, res: Response): Promise<Response> => {
  try {
    const car = await Vehicle.findById(req.params.id);
    if (!car) {
      return res.status(404).json({ message: 'Car not found' });
    }
    return res.json(car);
  } catch (error) {
    return res.status(500).json({ message: 'Failed to fetch car', error });
  }
};

export const getSimilarCars = async (req: Request, res: Response): Promise<Response> => {
  try {
    const baseCar = await Vehicle.findById(req.params.id);
    if (!baseCar) {
      return res.status(404).json({ message: 'Car not found' });
    }

    const priceRange = 0.1 * baseCar.price;
    const minPrice = baseCar.price - priceRange;
    const maxPrice = baseCar.price + priceRange;

    const similar = await Vehicle.find({
      _id: { $ne: baseCar._id },
      brand: baseCar.brand,
      type: baseCar.type,
      price: { $gte: minPrice, $lte: maxPrice },
    }).limit(4);

    return res.json(similar);
  } catch (error) {
    return res.status(500).json({ message: 'Failed to fetch similar cars', error });
  }
};

// -------------------- Helper: Find RTO --------------------
const findRtoMasterWithFallback = async (state?: string, city?: string) => {
  if (!state) return null;

  const lookups: Record<string, string>[] = [
    city ? { state, city } : null,
    { state },
  ].filter(Boolean) as Record<string, string>[];

  for (const query of lookups) {
    const rto = await RtoMaster.findOne(query);
    if (rto) return rto;
  }
  return null;
};

// -------------------- Get Variants With Pricing --------------------
export const getVariantsWithPricing = async (req: Request, res: Response): Promise<Response> => {
  try {
    const { id } = req.params;
    const state = typeof req.query.state === 'string' ? req.query.state : undefined;
    const city = typeof req.query.city === 'string' ? req.query.city : undefined;

    const vehicle = await Vehicle.findById(id);
    if (!vehicle) return res.status(404).json({ message: 'Car not found' });

    const variants = vehicle.variants && vehicle.variants.length
      ? vehicle.variants
      : [
          {
            _id: vehicle._id,
            name: vehicle.name,
            fuelType: vehicle.fuelType,
            transmission: vehicle.transmission,
            price:vehicle.price,
            colors: vehicle.colors,
            images: vehicle.images,
            safety: vehicle.safety,
            specifications: vehicle.specifications,
            features: vehicle.features,
            colorImages: vehicle.colorImages,
          },
        ];

    const variantsWithPricing = await Promise.all(
      variants.map(async (variant) => {
        const exShowroomPrice = Number(variant.price ?? vehicle.price ?? 0);
        const fuelType = (variant.fuelType || vehicle.fuelType || 'petrol').toLowerCase();

        const rto = await findRtoMasterWithFallback(state, city);

        let taxAmount = 0;
        let registrationFee = 0;
        let plateFee = 0;
        let handlingCharges = 0;
        let insurance = 0;
        let otherCharges = 0;
        let rtoCode = '';

        if (rto) {
          const fuelRate = rto.fuelTypeTaxes?.[fuelType as keyof typeof rto.fuelTypeTaxes] ?? 0;
          taxAmount = (exShowroomPrice * fuelRate) / 100;

          registrationFee = rto.registrationFee;
          plateFee = rto.plateFee;
          handlingCharges = rto.handlingCharges;
          insurance = rto.insurance;
          otherCharges = rto.otherCharges;
          rtoCode = rto?.rtoCode ?? '';
        }

        const onRoadPrice =
          exShowroomPrice +
          taxAmount +
          registrationFee +
          plateFee +
          handlingCharges +
          insurance +
          otherCharges;

        return {
          variantId: variant._id ?? null,
          name: variant.name,
          fuelType,
          transmission: variant.transmission,
          colors: variant.colors,
          images: variant.images,
          features: variant.features,
          colorImages: variant.colorImages,
          exShowroomPrice,
          onRoadPrice,
          rtoBreakup: rto
            ? {
                state: rto.state,
                city: rto.city,
                rtoCode,
                taxAmount,
                registrationFee,
                plateFee,
                handlingCharges,
                insurance,
                otherCharges,
              }
            : null,
        };
      })
    );

    return res.json({
      vehicleId: vehicle._id,
      state,
      city,
      variants: variantsWithPricing,
    });
  } catch (error) {
    return res.status(500).json({ message: 'Failed to fetch variants with pricing', error });
  }
};

export const calculateEmi = async (req: Request, res: Response): Promise<Response> => {
  try {
    const { loanAmount, interestRate, tenureMonths } = req.body;
    if (!loanAmount || !interestRate || !tenureMonths) {
      return res.status(400).json({ message: 'loanAmount, interestRate and tenureMonths are required' });
    }

    const principal = Number(loanAmount);
    const monthlyRate = Number(interestRate) / 12 / 100;
    const months = Number(tenureMonths);

    const factor = Math.pow(1 + monthlyRate, months);
    const emi = (principal * monthlyRate * factor) / (factor - 1 || 1);
    const totalPayable = emi * months;
    const totalInterest = totalPayable - principal;

    return res.json({ emi, totalInterest, totalPayable ,loanAmount});
  } catch (error) {
    return res.status(500).json({ message: 'Failed to calculate EMI', error });
  }
};

export const bookTestDrive = async (
  req: AuthenticatedRequest,
  res: Response
): Promise<Response> => {
  try {
    const userId = req.user?.id;
    if (!userId) {
      return res.status(401).json({ message: "Unauthorized" });
    }

    const {
      brand,
      modelName,
      date,
      timeSlot,
      state,
      city,
      address,
      customerName,
      fuelType,
      phoneNumber,
      alternatePhoneNumber,
      email,
      hasDrivingLicense,
    } = req.body;

    if (!brand || !modelName) {
      return res.status(400).json({ message: "brand and modelName are required" });
    }

    if (!date || !timeSlot || !phoneNumber || !customerName) {
      return res
        .status(400)
        .json({
          message: "date, timeSlot, phoneNumber and customerName are required",
        });
    }

    if (!hasDrivingLicense) {
      return res
        .status(400)
        .json({ message: "Driving license is required for test drive" });
    }

    // Look up vehicle by brand + model name for availability checks and canonical names.
    const vehicle = await Vehicle.findOne({ brand, name: modelName, fuelType:fuelType });
    if (vehicle) {
      if (vehicle.testDriveAvailable === false) {
        return res
          .status(400)
          .json({ message: "This vehicle is not available for test drive" });
      }
    }

    const booking = await Booking.create({
      userId,
      brand,
      modelName,
      date,
      timeSlot,
      state,
      city,
      address,
      customerName,
      phoneNumber,
      fuelType,
      alternatePhoneNumber,
      email,
      hasDrivingLicense,
      status: "pending",
    });

    return res.status(201).json(booking);
  } catch (error) {
    return res
      .status(500)
      .json({ message: "Failed to book test drive", error });
  }
};

export const addToCompare = async (
  req: AuthenticatedRequest,
  res: Response,
): Promise<Response> => {
  try {
    const vehicleId = req.params.id;

    if (req.user?.id) {
      const user = await User.findById(req.user.id);
      if (!user) {
        return res.status(404).json({ message: 'User not found' });
      }
      if (!user.compareList.find((id) => id.toString() === vehicleId)) {
        user.compareList.push(vehicleId as unknown as typeof user.compareList[number]);
        await user.save();
      }
      return res.json({ message: 'Added to compare list', compareList: user.compareList });
    }

    // Guest flow: store in in-memory set (shared across guests during process lifetime).
    guestCompareList.add(vehicleId);
    return res.json({ message: 'Added to compare list (guest)', compareList: Array.from(guestCompareList) });
  } catch (error) {
    return res.status(500).json({ message: 'Failed to add to compare list', error });
  }
};

export const removeFromCompare = async (
  req: AuthenticatedRequest,
  res: Response,
): Promise<Response> => {
  try {
    const vehicleId = req.params.id;

    if (req.user?.id) {
      const user = await User.findById(req.user.id);
      if (!user) {
        return res.status(404).json({ message: 'User not found' });
      }
      user.compareList = user.compareList.filter((id) => id.toString() !== vehicleId);
      await user.save();
      return res.json({ message: 'Removed from compare list', compareList: user.compareList });
    }

    // Guest flow
    guestCompareList.delete(vehicleId);
    return res.json({ message: 'Removed from compare list (guest)', compareList: Array.from(guestCompareList) });
  } catch (error) {
    return res.status(500).json({ message: 'Failed to remove from compare list', error });
  }
};

// Inline comparison: fetch up to 3 vehicles for side-by-side specs without persisting a set.
export const compareCarsInline = async (req: Request, res: Response): Promise<Response> => {
  try {
    const { ids } = req.query;
    if (!ids) {
      return res.status(400).json({ message: 'ids (comma-separated) are required' });
    }
    const idList = Array.isArray(ids)
      ? ids.flatMap((v) => String(v).split(','))
      : String(ids).split(',');
    const uniqueIds = Array.from(new Set(idList.map((id) => id.trim()).filter(Boolean)));
    if (uniqueIds.length < 2 || uniqueIds.length > 3) {
      return res
        .status(400)
        .json({ message: 'Provide between 2 and 3 vehicle ids for comparison' });
    }

    const vehicles = await Vehicle.find({ _id: { $in: uniqueIds } });
    if (vehicles.length !== uniqueIds.length) {
      return res.status(404).json({ message: 'One or more vehicles not found' });
    }

    return res.json(
      vehicles.map((v) => ({
        id: v._id,
        name: v.name,
        brand: v.brand,
        type: v.type,
        price: v.price,
        fuelType: v.fuelType,
        transmission: v.transmission,
        engine: v.engine,
        engineType: v.engineType,
        displacementCc: v.displacementCc,
        maxPower: v.maxPower,
        maxTorque: v.maxTorque,
        images: v.images,
        colors: v.colors,
        features: v.features,
        safety: v.safety,
        specifications: v.specifications,
        variants: v.variants,
      })),
    );
  } catch (error) {
    return res.status(500).json({ message: 'Failed to compare cars', error });
  }
};
