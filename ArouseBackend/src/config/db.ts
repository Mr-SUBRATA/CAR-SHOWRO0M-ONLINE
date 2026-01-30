import mongoose from 'mongoose';
import path from 'path';
import 'dotenv/config';

const connectDB = async (): Promise<void> => {
  try {
    const uri = process.env.MONGO_URI;
    if (!uri) {
      throw new Error('MONGO_URI is not defined');
    }

    const isAtlasX509 = uri.includes('MONGODB-X509');
    const isLocal = !isAtlasX509 && (process.env.NODE_ENV === 'development' || uri.includes('localhost') || uri.includes('127.0.0.1'));

    if (isLocal) {
      // Local development - connect without TLS/X.509
      await mongoose.connect(uri, {
        dbName: 'arouse_automotive',
      });
      console.log('MongoDB connected locally (development mode)');
    } else {
      // Production - use X.509 certificate authentication
      const pemPath = path.resolve(
        process.cwd(),
        'certs/mongo-client.pem'
      );

      await mongoose.connect(uri, {
        dbName: 'ArouseD',
        tls: true,
        tlsCertificateKeyFile: pemPath,
        // Node.js already trusts MongoDB Atlas's CA (DigiCert), no need for tlsCAFile
      });
      console.log('MongoDB connected using X.509 (production mode)');
    }

  } catch (error) {
    console.error('MongoDB connection error:', error);
    process.exit(1);
  }
};

export default connectDB;
