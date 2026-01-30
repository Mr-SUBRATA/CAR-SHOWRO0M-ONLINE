import { PutObjectCommand } from "@aws-sdk/client-s3";
import s3 from "../../src/config/s3";
import { v4 as uuidv4 } from "uuid";

interface UploadParams {
  buffer: Buffer;
  mimeType: string;
  folder: string;       // REQUIRED
  fileName?: string;
}

export const uploadToS3 = async ({
  buffer,
  mimeType,
  folder,
  fileName,
}: UploadParams): Promise<string> => {
  const key = `${folder}/${fileName ?? uuidv4()}`;

  await s3.send(
    new PutObjectCommand({
      Bucket: process.env.AWS_S3_BUCKET!,
      Key: key,
      Body: buffer,
      ContentType: mimeType,
    })
  );

  return `https://${process.env.AWS_S3_BUCKET}.s3.${process.env.AWS_REGION}.amazonaws.com/${key}`;
};
