const medicalService = require('../service/medicalTests.service');

exports.checkReport = (req, res) => {
    const reportText = req.body.text;

    if (!reportText) {
        return res.status(400).json({ error: 'Medical report text is required.' });
    }

    const result = medicalService.analyzeReport(reportText);
    if (!result.success) {
        return res.status(400).json({ error: result.message });
    }

    return res.status(200).json({ message: 'Report analyzed successfully.', data: result.data });
};
