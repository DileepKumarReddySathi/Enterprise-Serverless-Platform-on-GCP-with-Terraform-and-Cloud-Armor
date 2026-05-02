const monitoring = require("@google-cloud/monitoring");
const client = new monitoring.MetricServiceClient();

exports.handler = async (cloudEvent) => {
    const bucket = cloudEvent.bucket;
    const name = cloudEvent.name;
    const size = cloudEvent.size;

    console.log("Structured Log:", JSON.stringify({
        severity: "INFO",
        message: `Processed file: ${name}, size: ${size} bytes`,
        service_context: { service: "function-process" },
        metadata: { bucket, name, size }
    }));

    // Create custom metric in Cloud Monitoring
    const projectPath = client.projectPath(process.env.GCP_PROJECT);
    const timeSeriesData = {
        metric: {
            type: "custom.googleapis.com/files_processed",
            labels: { service: "function-process" },
        },
        resource: {
            type: "global",
            labels: { project_id: process.env.GCP_PROJECT },
        },
        points: [{
            interval: {
                endTime: { seconds: Math.floor(Date.now() / 1000) },
            },
            value: { int64Value: 1 },
        }],
    };

    try {
        await client.createTimeSeries({
            name: projectPath,
            timeSeries: [timeSeriesData],
        });
        console.log("Custom metric recorded");
    } catch (err) {
        console.error("Failed to record metric:", err);
    }
};
