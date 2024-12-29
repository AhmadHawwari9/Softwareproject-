const careRecipientService=require('../service/Emergencybutton.service');

const sendCareRecipientNotifications = async (req, res) => {
    const careRecipientId = req.user.id; // Assuming authentication middleware sets req.user
    try {
      // Fetch all caregivers for the care recipient
      const caregivers = await careRecipientService.getCaregiversByCareRecipientId(careRecipientId);
  
      if (caregivers.length === 0) {
        return res.status(404).json({
          message: `No caregivers found for care recipient ID: ${careRecipientId}`,
        });
      }
  
      // Send notification for each caregiver
      await careRecipientService.sendNotifications(careRecipientId, caregivers);
  
      res.status(200).json({
        message: 'Notifications sent successfully!',
      });
    } catch (error) {
      console.error('Error sending notifications:', error);
      res.status(500).json({ message: 'Failed to send notifications.', error: error.message });
    }
  };

  module.exports = {
    sendCareRecipientNotifications
};
