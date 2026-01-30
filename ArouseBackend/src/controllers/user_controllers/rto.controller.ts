import { Request, Response } from 'express';
import RtoMaster from '../../models/rtoPrice.model';
import Vehicle from '../../models/vehicle.model';

export const getFinalPrice = async (req: Request, res: Response): Promise<Response> => {
  try {
    const { id } = req.params; // vehicleId
    let { city, state, variantId } = req.query;

    if (!city) {
      return res.status(400).json({ message: 'city is required' });
    }

    const cityStr = Array.isArray(city) ? city[0] : String(city);
    const stateStr = state ? (Array.isArray(state) ? state[0] : String(state)) : undefined;
    const variantIdStr = variantId ? (Array.isArray(variantId) ? variantId[0] : String(variantId)) : undefined;

    const vehicle = await Vehicle.findById(id);
    if (!vehicle) return res.status(404).json({ message: 'Vehicle not found' });

    const variant = variantIdStr
      ? vehicle.variants?.find((v) => v._id?.toString() === variantIdStr) ?? null
      : null;

    if (variantIdStr && !variant) return res.status(404).json({ message: 'Variant not found' });

    const price = Number(variant?.price ?? vehicle.price ?? vehicle.price ?? 0);
 const fuelType = (variant?.fuelType || vehicle.fuelType || 'petrol').toLowerCase();

/* ---------------- RTO ---------------- */
const rto = await RtoMaster.findOne({ city: cityStr, ...(stateStr && { state: stateStr }) });
if (!rto) return res.status(404).json({ message: 'RTO charges not found for this location' });

// Convert Map to object
const fuelTaxes = rto.fuelTypeTaxes instanceof Map
  ? Object.fromEntries(rto.fuelTypeTaxes)
  : rto.fuelTypeTaxes || {};

const taxRate = fuelTaxes[fuelType] ?? 0;
const taxAmount = (price * taxRate) / 100;

    const onRoadPrice =
      price +
      taxAmount +
      (rto.registrationFee || 0) +
      (rto.plateFee || 0) +
      (rto.handlingCharges || 0) +
      (rto.insurance || 0) +
      (rto.otherCharges || 0);

    return res.json({
      vehicleId: vehicle._id,
      variantId: variant?._id ?? null,
      modelName: vehicle.name,
      brand: vehicle.brand,
      fuelType,
      price,
      rtoDetails: {
        state: rto.state,
        city: rto.city,
        rtoCode: rto.rtoCode,
        taxRate,
        taxAmount,
        registrationFee: rto.registrationFee,
        plateFee: rto.plateFee,
        handlingCharges: rto.handlingCharges,
        insurance: rto.insurance,
        otherCharges: rto.otherCharges,
      },
      onRoadPrice,
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Failed to fetch price', error });
  }
};


export const getAllRtoCities = async (req: Request, res: Response) => {
  try {
    const cities = await RtoMaster.distinct('city');

    return res.status(200).json({
      count: cities.length,
      cities,
    });
  } catch (error) {
    console.error('GET RTO CITIES ERROR:', error);
    return res.status(500).json({
      message: 'Failed to fetch RTO cities',
    });
  }

}

 export const getAllRtoStates = async (req: Request, res: Response) => {
  try {
    const states = await RtoMaster.distinct('state');

    return res.status(200).json({
      count: states.length,
      states,
    });
  } catch (error) {
    console.error('GET RTO States ERROR:', error);
    return res.status(500).json({
      message: 'Failed to fetch RTO states',
    });
  }
};
