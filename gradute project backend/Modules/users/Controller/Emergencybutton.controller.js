const careRecipientService=require('../service/Emergencybutton.service');

const sendCareRecipientNotifications = async (req, res) => {
  const careRecipientId = req.user.id; // Assuming authentication middleware sets req.user
  const { latitude, longitude } = req.body;

  if (!latitude || !longitude) {
    return res.status(400).json({ message: 'Coordinates (latitude and longitude) are required.' });
  }

  try {
    // Fetch caregivers
    const caregivers = await careRecipientService.getCaregiversByCareRecipientId(careRecipientId);

    if (caregivers.length === 0) {
      return res.status(404).json({
        message: `No caregivers found for care recipient ID: ${careRecipientId}`,
      });
    }

    // Send notifications with concatenated coordinates
    await careRecipientService.sendNotifications(careRecipientId, caregivers, latitude, longitude);

    res.status(200).json({
      message: 'Notification with coordinates sent successfully!',
    });
  } catch (error) {
    console.error('Error sending notification:', error);
    res.status(500).json({ message: 'Failed to send notification.', error: error.message });
  }
};



  module.exports = {
    sendCareRecipientNotifications
};
