exports.handler = async (event) => {
    for (const record of event.Records) {
        const bucket = record.s3.bucket.name;
        const key = decodeURIComponent(record.s3.object.key.replace(/\+/g, " "));
        const size = record.s3.object.size;

        console.log("Structured Log:", JSON.stringify({
            severity: "INFO",
            message: `Processed file: ${key}, size: ${size} bytes`,
            service_context: { service: "function-process" },
            metadata: { bucket, key, size }
        }));

        // Custom Metric simulation
        console.log(`MONITORING|${size}|1|count|FilesProcessed|#service:function-process`);
    }
};
