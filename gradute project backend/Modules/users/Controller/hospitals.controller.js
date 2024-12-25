const hospitalService=require('../service/hospitals.service');

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
  
  module.exports = {
    getAllHospitals,
  };