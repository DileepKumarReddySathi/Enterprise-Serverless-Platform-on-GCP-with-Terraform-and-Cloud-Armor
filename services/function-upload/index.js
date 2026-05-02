const { Storage } = require("@google-cloud/storage");
const Busboy = require("busboy");

const storage = new Storage();
const BUCKET_NAME = process.env.BUCKET_NAME;

exports.handler = async (req, res) => {
    console.log("Structured Log:", JSON.stringify({
        severity: "INFO",
        message: "Received upload request",
        service_context: { service: "function-upload" }
    }));

    if (req.method !== "POST") {
        return res.status(405).send("Method Not Allowed");
    }

    const busboy = Busboy({ headers: req.headers });
    let fileFound = false;

    busboy.on("file", (fieldname, file, info) => {
        const { filename, contentType } = info;
        console.log(`Processing file: ${filename}`);
        fileFound = true;

        const bucket = storage.bucket(BUCKET_NAME);
        const gcsFile = bucket.file(filename);

        const stream = gcsFile.createWriteStream({
            metadata: { contentType },
        });

        file.pipe(stream);

        stream.on("error", (err) => {
            console.error("Upload error:", err);
            res.status(500).send(err.message);
        });

        stream.on("finish", () => {
            res.status(201).send({
                message: "File uploaded successfully",
                filename,
                bucket: BUCKET_NAME,
            });
        });
    });

    busboy.on("finish", () => {
        if (!fileFound) {
            res.status(400).send("No file uploaded");
        }
    });

    req.pipe(busboy);
};
