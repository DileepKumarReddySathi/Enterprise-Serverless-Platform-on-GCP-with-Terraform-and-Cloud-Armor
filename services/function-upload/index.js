const { S3Client, PutObjectCommand } = require("@aws-sdk/client-s3");
const multipart = require("lambda-multipart-parser");

const s3 = new S3Client({});
const BUCKET_NAME = process.env.BUCKET_NAME;

exports.handler = async (event) => {
    console.log("Structured Log:", JSON.stringify({
        severity: "INFO",
        message: "Received upload request",
        service_context: { service: "function-upload" }
    }));

    try {
        const result = await multipart.parse(event);
        if (!result.files || result.files.length === 0) {
            return {
                statusCode: 400,
                body: JSON.stringify({ message: "No file provided" }),
            };
        }

        const file = result.files[0];
        const params = {
            Bucket: BUCKET_NAME,
            Key: file.filename,
            Body: file.content,
            ContentType: file.contentType,
        };

        await s3.send(new PutObjectCommand(params));

        return {
            statusCode: 201,
            body: JSON.stringify({
                filename: file.filename,
                bucket: BUCKET_NAME,
            }),
        };
    } catch (error) {
        console.error("Structured Log:", JSON.stringify({
            severity: "ERROR",
            message: error.message,
            service_context: { service: "function-upload" }
        }));
        return {
            statusCode: 500,
            body: JSON.stringify({ message: "Internal Server Error" }),
        };
    }
};
