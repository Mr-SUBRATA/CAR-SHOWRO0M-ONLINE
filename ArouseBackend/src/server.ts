import dotenv from 'dotenv';
import app from './app';
import connectDB from './config/db';

dotenv.config();

const PORT = process.env.PORT ? Number(process.env.PORT) : 5000;

const startServer = async () => {
  try {
    await connectDB();
   app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});

  } catch (error) {
    console.error('Failed to start server', error);
    process.exit(1);
  }
};

startServer();
