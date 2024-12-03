const scheduleService = require('../service/scheduleforcaregiver.Service');

const getSchedule = async (req, res) => {
  try {
    const userId = req.user.id;  // User ID is extracted from the authentication middleware

    // Fetch the schedule using the user ID
    const scheduleData = await scheduleService.getScheduleByUserId(userId);

    if (scheduleData.length === 0) {
      return res.status(404).json({ message: 'No schedule found for this user' });
    }

    return res.status(200).json(scheduleData);
  } catch (error) {
    return res.status(500).json({ message: 'Server error: ' + error.message });
  }
};


const updateSchedule = async (req, res) => {
    try {
      const { name, date, time } = req.body;
      const scedual_id = req.params.scedual_id;  // Extracting scedual_id from URL params
      const userId = req.user.id; // Assuming this is extracted from the verified token
  
      // Log inputs to ensure all required data is being passed
      console.log('Inputs:', { scedual_id, name, date, time, userId });
  
      const updatedSchedule = await scheduleService.updateSchedule(
        scedual_id, name, date, time, userId
      );
  
      if (!updatedSchedule) {
        return res.status(404).json({ message: 'Schedule not found or not updated.' });
      }
  
      res.status(200).json({ message: 'Schedule updated successfully', data: updatedSchedule });
    } catch (error) {
      console.error('Error updating schedule:', error);
      res.status(500).json({ message: 'Internal server error' });
    }
  };
  

  const deleteSchedule = async (req, res) => {
    try {
      const scedual_id = req.params.scedual_id;  // Extracting scedual_id from URL params
      const userId = req.user.id; // Assuming user is authenticated and ID is extracted from token
  
      // Log the inputs for debugging
      console.log('Inputs:', { scedual_id, userId });
  
      // Call service to delete the schedule
      const deletedSchedule = await scheduleService.deleteSchedule(scedual_id, userId);
  
      if (!deletedSchedule) {
        return res.status(404).json({ message: 'Schedule not found or could not be deleted.' });
      }
  
      res.status(200).json({ message: 'Schedule deleted successfully' });
    } catch (error) {
      console.error('Error deleting schedule:', error);
      res.status(500).json({ message: 'Internal server error' });
    }
  };

  const addSchedule = async (req, res) => {
    try {
      const { name, date, time } = req.body;
      const userId = req.user.id; // Assuming this is extracted from the verified token
  
      // Log inputs to ensure all required data is being passed
      console.log('Inputs:', { name, date, time, userId });
  
      // Call service to add the new schedule
      const newSchedule = await scheduleService.addSchedule(name, date, time, userId);
  
      if (!newSchedule) {
        return res.status(400).json({ message: 'Failed to add schedule.' });
      }
  
      res.status(200).json({ message: 'Schedule added successfully', data: newSchedule });
    } catch (error) {
      console.error('Error adding schedule:', error);
      res.status(500).json({ message: 'Internal server error' });
    }
  };
    

module.exports = { getSchedule,updateSchedule,deleteSchedule,addSchedule };
