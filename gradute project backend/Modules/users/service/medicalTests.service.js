const normalizeText = (rawText) => {
    return rawText
        .replace(/\n/g, ' ') // Replace line breaks with spaces
        .replace(/\s+/g, ' ') // Replace multiple spaces with a single space
        .replace(/\s*\.\s*/g, '.') // Remove spaces around dots
        .replace(/\s*:\s*/g, ':') // Remove spaces around colons
        .trim();
};

exports.analyzeReport = (rawText) => {
    const normalizedText = normalizeText(rawText);

    const results = {
        heartRate: null,
        fastingBloodSugar: null,
        haemoglobin: null,
        whiteBloodCells: null,
        bloodPressure: null,
        hdl: null,
        ldl: null,
    };

    const patterns = {
        heartRate: /A\.Heart rate:\s*(\d+)/i,
        fastingBloodSugar: /B\.Fasting Blood Sugar:\s*(\d+)/i,
        haemoglobin: /C\.Haemoglobin:\s*(\d+)/i,
        whiteBloodCells: /D\.white blood cells:\s*(\d+)/i,
        bloodPressure: /E\.Blood pressure:\s*(\d+)\/(\d+)/i, // Capture systolic and diastolic values
        hdl: /F\.HDL:\s*(\d+)/i,
        ldl: /G\.LDL:\s*(\d+)/i,
    };

    // Extract values using the regular expressions
    for (const [key, regex] of Object.entries(patterns)) {
        const match = normalizedText.match(regex);
        if (match && match[1]) {
            // Handle blood pressure specially (systolic/diastolic)
            if (key === 'bloodPressure') {
                results[key] = {
                    systolic: parseInt(match[1], 10),
                    diastolic: parseInt(match[2], 10),
                };
            } else {
                results[key] = parseInt(match[1], 10);
            }
        } else {
            results[key] = null;
        }
    }

    // Check for missing fields
    const missingFields = Object.entries(results)
        .filter(([_, value]) => value === null)
        .map(([key]) => key);

    if (missingFields.length > 0) {
        return {
            success: false,
            message: `Missing values for: ${missingFields.join(', ')}`,
        };
    }

    // Analyze the values
    const analysis = {
        heartRate: results.heartRate >= 60 && results.heartRate <= 100 ? 'Normal' : 'Abnormal',
        fastingBloodSugar: results.fastingBloodSugar < 100 ? 'Normal' : 'Above Normal',
        haemoglobin: results.haemoglobin >= 13.5 && results.haemoglobin <= 17.5 ? 'Normal' : 'Abnormal',
        whiteBloodCells: results.whiteBloodCells >= 4000 && results.whiteBloodCells <= 11000 ? 'Normal' : 'Abnormal',
        bloodPressure: (results.bloodPressure.systolic >= 90 && results.bloodPressure.systolic <= 120 && 
                        results.bloodPressure.diastolic >= 60 && results.bloodPressure.diastolic <= 80) 
                        ? 'Normal' : 'Abnormal',
        hdl: results.hdl >= 40 ? 'Normal' : 'Below Normal',
        ldl: results.ldl <= 130 ? 'Normal' : 'Above Normal',
    };

    return {
        success: true,
        data: analysis,
    };
};
