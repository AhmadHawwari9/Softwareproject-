const medicalReportService = require('../service/History.service');

exports.getReportsByUserId = async (req, res) => {
  const userId = req.params.user_id;
  
  try {
    // Call the service to get reports for the specific user
    const reports = await medicalReportService.getReportsForUser(userId);
    
    if (!reports || reports.length === 0) {
      return res.status(404).json({ message: 'No medical reports found for this user' });
    }
    
    res.status(200).json(reports);
  } catch (error) {
    console.error('Error fetching reports:', error);
    res.status(500).json({ message: 'Server error' });
  }
};
