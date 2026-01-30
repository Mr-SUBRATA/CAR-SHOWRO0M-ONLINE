import { Request, Response } from 'express';
import RtoMaster from '../../models/rtoPrice.model';
import multer from 'multer';
import csv from 'csv-parser';
import { Readable } from 'stream';
import { AnyBulkWriteOperation } from 'mongodb';


export const csvUpload = multer({
  storage: multer.memoryStorage(),
  fileFilter: (_req, file, cb) => {
    if (!file.originalname.endsWith('.csv')) {
      cb(new Error('Only CSV files allowed'));
    }
    cb(null, true);
  },
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
});
const buildFuelRatesFromRow = (row: any) => {
  const map: Record<string, number> = {};
  ['petrol', 'diesel', 'cng', 'electric'].forEach((fuel) => {
    const key = `fuel_${fuel}`;
    if (row[key] !== undefined && row[key] !== '') {
      const num = Number(row[key]);
      if (!Number.isNaN(num)) map[fuel] = num;
    }
  });
  return map;
};

export const uploadRtoCsv = async (req: Request, res: Response) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'CSV file is required' });
    }

    const rows: any[] = [];
    const stream = Readable.from(req.file.buffer);

    await new Promise<void>((resolve, reject) => {
      stream
        .pipe(csv())
        .on('data', (data) => rows.push(data))
        .on('end', resolve)
        .on('error', reject);
    });

    const bulkOps: AnyBulkWriteOperation<any>[] = rows
      .map((row) => {
        const state = row.state?.trim();
        const city = row.city?.trim();
        const rtoCode = row.rtoCode?.trim();

        if (!city) return null;

        return {
          updateOne: {
            filter: { state, city },
            update: {
              $set: {
                state,
                city,
                rtoCode,
                fuelTypeTaxes: buildFuelRatesFromRow(row),
                registrationFee: Number(row.registrationFee) || 0,
                plateFee: Number(row.plateFee) || 0,
                handlingCharges: Number(row.handlingCharges) || 0,
                insurance: Number(row.insurance) || 0,
                otherCharges: Number(row.otherCharges) || 0,
              },
            },
            upsert: true,
          },
        };
      })
      .filter(Boolean) as AnyBulkWriteOperation<any>[];


    if (!bulkOps.length) {
      return res.status(400).json({ message: 'No valid rows found in CSV' });
    }

    await RtoMaster.bulkWrite(bulkOps);

    return res.status(200).json({
      message: 'RTO CSV uploaded successfully',
      recordsProcessed: bulkOps.length,
    });
  } catch (error: any) {
    console.error('CSV UPLOAD ERROR:', error.message);
    return res.status(500).json({
      message: 'Failed to upload RTO CSV',
      error: error.message,
    });
  }
};

export const exportRtoCsv = async (req: Request, res: Response) => {
  try {
    const rtoList = await RtoMaster.find().lean();

    if (!rtoList.length) {
      return res.status(404).json({ message: 'No RTO data found' });
    }

    // CSV headers (keep same order as import)
    const headers = [
      'state',
      'city',
      'rtoCode',
      'fuel_petrol',
      'fuel_diesel',
      'fuel_cng',
      'fuel_electric',
      'registrationFee',
      'plateFee',
      'handlingCharges',
      'insurance',
      'otherCharges',
    ];


    const csvRows: string[] = [];
    csvRows.push(headers.join(','));

    for (const rto of rtoList) {
      const fuel =
        rto.fuelTypeTaxes instanceof Map
          ? Object.fromEntries(rto.fuelTypeTaxes)
          : rto.fuelTypeTaxes ?? {};

      const row = [
        rto.state ?? '',
        rto.city ?? '',
        rto.rtoCode ?? '',
        fuel.petrol ?? '',
        fuel.diesel ?? '',
        fuel.cng ?? '',
        fuel.electric ?? '',
        rto.registrationFee ?? 0,
        rto.plateFee ?? 0,
        rto.handlingCharges ?? 0,
        rto.insurance ?? 0,
        rto.otherCharges ?? 0,
      ];

      csvRows.push(row.map((v) => `"${v}"`).join(','));
    }



    const csvData = csvRows.join('\n');

    res.setHeader('Content-Type', 'text/csv');
    res.setHeader(
      'Content-Disposition',
      'attachment; filename="rto-pricing-export.csv"'
    );

    return res.status(200).send(csvData);
  } catch (error: any) {
    console.error('EXPORT CSV ERROR:', error.message);
    return res.status(500).json({
      message: 'Failed to export RTO CSV',
    });
  }
};

export const upsertRtoMaster = async (req: Request, res: Response): Promise<Response> => {
  try {
    const {
      state,
      city,
      rtoCode,
      fuelTypeTaxes,
      registrationFee,
      plateFee,
      handlingCharges,
      insurance,
      otherCharges,
    } = req.body;

    if (!city) {
      return res.status(400).json({ message: 'city is required' });
    }

    // Coerce fuelTypeRates to a map of numbers; frontend sends a single fuel string
    const normalizeFuelRates = (input: any) => {
      if (!input) return {};
      if (typeof input === 'string') return { [input]: 0 };
      if (typeof input === 'object') {
        const map: Record<string, number> = {};
        Object.entries(input).forEach(([k, v]) => {
          const num = Number(v);
          if (!Number.isNaN(num)) map[k] = num;
        });
        return map;
      }
      return {};
    };

    const filter = state ? { state, city } : { city };

    const rtoData = await RtoMaster.findOneAndUpdate(
      filter,
      {
        state,
        city,
        rtoCode,
        fuelTypeTaxes: normalizeFuelRates(fuelTypeTaxes),
        registrationFee: Number(registrationFee) || 0,
        plateFee: Number(plateFee) || 0,
        handlingCharges: Number(handlingCharges) || 0,
        insurance: Number(insurance) || 0,
        otherCharges: Number(otherCharges) || 0,
      },
      { upsert: true, new: true, setDefaultsOnInsert: true }
    );

    return res.status(201).json(rtoData);
  } catch (error) {
    return res.status(500).json({ message: 'Failed to upsert RTO master', error });
  }
};

