const { validationResult } = require('express-validator');
const { createCaregiver,getAllCaregivers ,getAllHospitals} = require('../service/caregiverRequestToTheAdmin.service');
const fileManager = require('../../fileMannager/services/FileMannager.service'); 
const caregiverService = require('../service/caregiverRequestToTheAdmin.service');

const createCaregiverUsingPost = async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(422).json({ errors: errors.array() });
  }

  const { first_name, last_name, email, age, password, typeofuser } = req.body;
  const photo = req.files['photo'] ? req.files['photo'][0] : null;
  const cv = req.files['file'] ? req.files['file'][0] : null;

  if (!photo || !cv) {
    return res.status(400).json({ error: 'Both photo and CV are required.' });
  }

  try {
    const photoId = await fileManager.filecreate(photo);
    const cvId = await fileManager.filecreate(cv);

    const caregiver = await createCaregiver(first_name, last_name, email, age, password, typeofuser, photoId, cvId);

    return res.status(201).json({
      message: 'Caregiver application submitted successfully',
      caregiverId: caregiver.caregiverId
    });
  } catch (error) {
    console.error('Error submitting caregiver application: ', error);
    return res.status(500).json({ error: 'An error occurred while submitting the application' });
  }
};

const getCaregiver = async (req, res) => {
    try {
      const caregivers = await getAllCaregivers();
      
      if (caregivers.length === 0) {
        return res.status(404).json({ message: 'No caregivers found' });
      }
  
      res.json(caregivers);
    } catch (err) {
      console.error('Error fetching caregivers data:', err);
      res.status(500).json({ error: 'Internal server error' });
    }
  };


  const moveCaregiverToUser = (req, res) => {
    const requestId = req.params.requestId;
  
    caregiverService.moveCaregiverToUser(requestId)
      .then(response => {
        res.status(200).json(response);
      })
      .catch(err => {
        console.error(err);
        res.status(500).json({ error: 'An error occurred while processing your request' });
      });
  };

  const deleteCaregiverRequest = (req, res) => {
    const requestId = req.params.requestId;
  
    caregiverService.deleteCaregiverRequest(requestId)
      .then(response => {
        res.status(200).json(response);
      })
      .catch(err => {
        console.error(err);
        res.status(500).json({ error: 'An error occurred while processing your request' });
      });
  };

  const getHospital = async (req, res) => {
    try {
      const hospitals = await getAllHospitals();
      
      if (hospitals.length === 0) {
        return res.status(404).json({ message: 'No hospitals found' });
      }
  
      res.json(hospitals);
    } catch (err) {
      console.error('Error fetching hospital data:', err);
      res.status(500).json({ error: 'Internal server error' });
    }
  };
  
module.exports = {
  createCaregiverUsingPost,
  getCaregiver,
  moveCaregiverToUser,
  deleteCaregiverRequest,
  getHospital
};
