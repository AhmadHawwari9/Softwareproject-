const hospitalService=require('../service/hospitals.service');
const {filecreate,filedelete}= require('../../fileMannager/services/FileMannager.service');


const getAllHospitals = async (req, res) => {
    try {
      const hospitals = await hospitalService.getHospitalsWithImagePaths();
      res.status(200).json({
        message: 'Hospitals fetched successfully!',
        data: hospitals,
      });
    } catch (error) {
      console.error('Error fetching hospitals:', error);
      res.status(500).json({ message: 'Failed to fetch hospitals.', error: error.message });
    }
  };

  const getHospitalByUserId = async (req, res) => {
    const userId = req.user.id; 
  
    try {
      const hospital = await hospitalService.getHospitalWithImagePathByUserId(userId);
      if (!hospital) {
        return res.status(404).json({
          message: `No hospital found for User_id: ${userId}`,
        });
      }
  
      res.status(200).json({
        message: 'Hospital fetched successfully!',
        data: hospital,
      });
    } catch (error) {
      console.error('Error fetching hospital:', error);
      res.status(500).json({ message: 'Failed to fetch hospital.', error: error.message });
    }
  };
  
  const updateHospital = async (req, res) => {
    try {
      const User_id = req.user.id;
      const { name, location, description, clinics, workingHours, doctors, contact } = req.body;
      const file = req.file;
  
      if (!name || !location) {
        return res.status(400).json({ message: 'Name and location are required.' });
      }
  
      // Handle file upload and get image_id
      let image_id = null;
      if (file) {
        image_id = await filecreate(file); // Use filecreate for file upload
        
        // Update image_id in the users table
        await hospitalService.updateUserImage(User_id, image_id);
  
        // Update image_id in the caregiverrequesttoadmin table if needed
        await hospitalService.updateCaregiverImage(User_id, image_id);
      }
  
      // Check if a hospital record exists for the user
      const existingHospital = await hospitalService.getHospitalByUserId(User_id);
  
      if (existingHospital) {
        // Delete the existing hospital record
        await hospitalService.deleteHospitalById(existingHospital.id);
      }
  
      // Create new hospital record
      const newHospitalId = await hospitalService.addHospital({
        User_id,
        name,
        image_id,
        location,
        description,
        clinics,
        workingHours,
        doctors,
        contact,
      });
  
      res.status(200).json({
        message: 'Hospital data updated successfully!',
        hospitalId: newHospitalId,
      });
    } catch (error) {
      console.error('Error updating hospital data:', error);
      res.status(500).json({ message: 'Failed to update hospital data.', error: error.message });
    }
  };
  
  
  
  module.exports = {
    getAllHospitals,
    getHospitalByUserId,
    updateHospital
  };