const careRecipientService=require('../service/Emergencybutton.service');

const sendCareRecipientNotifications = async (req, res) => {
  const careRecipientId = req.user.id; // Assuming authentication middleware sets req.user
  const { latitude, longitude } = req.body;

  if (!latitude || !longitude) {
    return res.status(400).json({ message: 'Coordinates (latitude and longitude) are required.' });
  }

  try {
    // Step 1: Fetch doctors_ids for the patient from patient_doctors table
    const doctorsIds = await careRecipientService.getDoctorsIds(careRecipientId);

    if (!doctorsIds || doctorsIds.length === 0) {
      return res.status(404).json({ message: 'No doctors found for this patient.' });
    }

    // Step 2: Fetch caregivers whose IDs are in the doctors_ids array
    const caregivers = await careRecipientService.getCaregiversByDoctorIds(doctorsIds);

    if (caregivers.length === 0) {
      return res.status(404).json({
        message: `No caregivers found for care recipient ID: ${careRecipientId}`,
      });
    }

    // Step 3: Send notifications with concatenated coordinates
    await careRecipientService.sendNotifications(careRecipientId, caregivers, latitude, longitude);

    res.status(200).json({
      message: 'Notification with coordinates sent successfully!',
    });
  } catch (error) {
    console.error('Error sending notification:', error);
    res.status(500).json({ message: 'Failed to send notification.', error: error.message });
  }
};

const addPatientDoctors = async (req, res) => {
  const patientId = req.user.id; // Patient ID from authentication
  const { doctors_ids } = req.body; // Array of doctor IDs from request body

  if (!doctors_ids || !Array.isArray(doctors_ids)) {
    return res.status(400).json({ message: 'doctors_ids must be an array of IDs.' });
  }

  try {
    // Step 1: Delete existing doctors from the patient_doctors table
    await careRecipientService.deleteExistingPatientDoctors(patientId);

    // Step 2: Call service to insert new data
    await careRecipientService.addPatientDoctors(patientId, doctors_ids);

    res.status(200).json({ message: 'Data inserted successfully.' });
  } catch (error) {
    console.error('Error inserting data:', error);
    res.status(500).json({ message: 'Failed to insert data.', error: error.message });
  }
};


const getDoctorsEmails = async (req, res) => {
  const patientId = req.user.id; // Get patient ID from authentication

  try {
    // Step 1: Fetch doctors_ids for the patient from patient_doctors table
    const doctorsIds = await careRecipientService.getDoctorsIds(patientId);

    if (!doctorsIds || doctorsIds.length === 0) {
      return res.status(404).json({ message: 'No doctors found for this patient.' });
    }

    // Step 2: Fetch the emails of the doctors from the users table using the doctors_ids
    const doctorsEmails = await careRecipientService.getDoctorsEmails(doctorsIds);

    res.status(200).json({ doctors_emails: doctorsEmails });
  } catch (error) {
    console.error('Error fetching doctors emails:', error);
    res.status(500).json({ message: 'Failed to fetch doctors emails.', error: error.message });
  }
};  

  module.exports = {
    sendCareRecipientNotifications,
    addPatientDoctors,
    getDoctorsEmails
};
