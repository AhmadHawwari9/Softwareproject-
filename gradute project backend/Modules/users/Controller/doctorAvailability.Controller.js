const doctorAvailabilityService = require('../service/doctorAvailability.Service');

const setDoctorAvailability = async (req, res) => {
  try {
    const doctorId = req.user.id; // Extract doctor ID from authenticated user
    const { days, startTime, endTime, appointmentDuration } = req.body;

    if (!days || !startTime || !endTime || !appointmentDuration) {
      return res.status(400).json({ message: 'Days, start time, end time, and appointment duration are required.' });
    }

    // Save or update the doctor's availability
    await doctorAvailabilityService.saveDoctorAvailability(doctorId, days, startTime, endTime, appointmentDuration);

    res.status(200).json({ message: 'Availability saved successfully.' });
  } catch (error) {
    console.error('Error saving availability:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};



const getDoctorAvailability = async (req, res) => {
  try {
    const doctorId = req.user.id; // Get doctorId from the authenticated user
  
    const availability = await doctorAvailabilityService.getDoctorAvailability(doctorId);
  
    if (!availability) {
      return res.status(404).json({ message: 'No availability found for this doctor.' });
    }
  
    // Return the availability along with the doctorId (user_id)
    res.status(200).json({
      user_id: doctorId,  // Include the user_id in the response
      availability: availability,
    });
  } catch (error) {
    console.error('Error retrieving availability:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

  const fetchDoctorAvailability = async (req, res) => {
    try {
      const { id } = req.params; // Get the doctor ID from params
  
      const availability = await doctorAvailabilityService.findAvailabilityByDoctorId(id);
  
      if (!availability) {
        return res.status(404).json({ message: 'No availability found for this doctor.' });
      }
  
      res.status(200).json(availability);
    } catch (error) {
      console.error('Error retrieving availability:', error);
      res.status(500).json({ message: 'Internal server error' });
    }
  };
  

module.exports = { setDoctorAvailability,
    getDoctorAvailability,
    fetchDoctorAvailability
 };
