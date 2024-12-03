const careRecipientService = require('../service/Tablecarerecipientlist.service');

const getCareRecipients = async (req, res) => {
  try {
    const careGiverId = req.user.id; // Extract `Care_giverid` from authenticated user

    // Fetch the care recipients' emails for this caregiver
    const recipients = await careRecipientService.getCareRecipientsByCareGiverId(careGiverId);

    if (recipients.length === 0) {
      return res.status(404).json({ message: 'No care recipients found for this caregiver.' });
    }

    res.status(200).json({ message: 'Care recipients fetched successfully.', data: recipients });
  } catch (error) {
    console.error('Error fetching care recipients:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

module.exports = { getCareRecipients };
