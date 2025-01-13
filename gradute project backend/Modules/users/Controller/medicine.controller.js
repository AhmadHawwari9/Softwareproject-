const medicationScheduleService=require('../service/medicine.service');
const db = require('../../../db/database');


const getMedications = async (req, res) => {
    try {
      const doctorId = req.params.doctorId;  // Get doctorId from params
      const patientId = req.user.id; // Get patientId from the authenticated user
  
      // Call the service to get medication schedule for this doctor and patient
      const medications = await medicationScheduleService.getMedications(doctorId, patientId);
  
      if (!medications || medications.length === 0) {
        return res.status(404).json({ message: 'No medications found for this doctor and patient.' });
      }
  
      // Process the medications to include "X times/day" format
      const processedMedications = medications.map(medication => {
        const timings = JSON.parse(medication.timings); // Parse JSON array of timings
        const timesPerDay = timings.length;
        medication.timesPerDay = `${timesPerDay} times/day`; // Add "times/day" to the response
        return medication;
      });
  
      res.status(200).json(processedMedications); // Send response with processed medications
    } catch (error) {
      console.error('Error retrieving medications:', error);
      res.status(500).json({ message: 'Internal server error' });
    }
  };


  const getAllMedicationsForPatient = async (req, res) => {
    try {
      const patientId = req.user.id; // Get patientId from the authenticated user
      
      // Call the service to get all medications for the patient
      const medications = await medicationScheduleService.fetchMedicationsForPatient(patientId);
      
      if (!medications || medications.length === 0) {
        return res.status(404).json({ message: 'No medications found for this patient.' });
      }
      
      // Process the medications to include "X times/day" format
      const processedMedications = medications.map(medication => {
        const timings = JSON.parse(medication.timings); // Parse JSON array of timings
        const timesPerDay = timings.length;
        medication.timesPerDay = `${timesPerDay} times/day`; // Add "times/day" to the response
        return medication;
      });
      
      res.status(200).json(processedMedications); // Send response with processed medications
    } catch (error) {
      console.error('Error retrieving medications:', error);
      res.status(500).json({ message: 'Internal server error' });
    }
  };

  const createNewMedication = async (req, res) => {
    try {
      const doctorId = req.user.id; 
      const { patientId, medicineName, dosage, timings } = req.body;
  
      if (!patientId || !medicineName || !dosage || !timings) {
        return res.status(400).json({ message: 'All fields are required.' });
      }
  
      if (!Array.isArray(timings)) {
        return res.status(400).json({ message: 'Timings must be a JSON array.' });
      }
  
      const newMedicationId = await medicationScheduleService.createMedicationRecord({
        patientId,
        doctorId,
        medicineName,
        dosage,
        timings: JSON.stringify(timings), 
      });
  
      res.status(201).json({
        message: 'Medication added successfully.',
        medicationId: newMedicationId,
      });
    } catch (error) {
      console.error('Error adding medication:', error);
      res.status(500).json({ message: 'Internal server error' });
    }
  };
  
  const getMedicationsForPatientById = async (req, res) => {
    try {
      const patientId = req.params.patientId; 
      
      const medications = await medicationScheduleService.getMedicationsByPatientId(patientId);
      
      if (!medications || medications.length === 0) {
        return res.status(404).json({ message: 'No medications found for this patient.' });
      }
      
      const processedMedications = medications.map(medication => {
        const timings = JSON.parse(medication.timings); 
        const timesPerDay = timings.length;
        medication.timesPerDay = `${timesPerDay} times/day`; 
        return medication;
      });
      
      res.status(200).json(processedMedications); 
    } catch (error) {
      console.error('Error retrieving medications:', error);
      res.status(500).json({ message: 'Internal server error' });
    }
  };
  
  
  const getUserEmailByToken = async (req, res) => {
    try {
      const userId = req.user.id; 
      
      const email = await medicationScheduleService.getUserEmailById(userId);
      
      if (!email) {
        return res.status(404).json({ message: 'User not found' });
      }
      
      res.status(200).json({ email: email }); 
    } catch (error) {
      console.error('Error retrieving user email:', error);
      res.status(500).json({ message: 'Internal server error' });
    }
  };
  

const deleteMedicationById = async (req, res) => {
  try {
    const medicationId = req.params.id; // Get the medication ID from the URL params

    const result = await medicationScheduleService.deleteMedicationById(medicationId);

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Medication not found or already deleted.' });
    }

    res.status(200).json({ message: 'Medication deleted successfully.' });
  } catch (error) {
    console.error('Error deleting medication:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

const fetchMedicationsReminder = async (req, res) => {
  const senderId = req.user.id; // Authenticated doctor
  const receiverId = senderId; // Patient

  try {
    const medications = await medicationScheduleService.getMedicationsForUser(receiverId);

    // Get current date and time
    const currentDate = new Date().toISOString().slice(0, 10); // YYYY-MM-DD
    const currentTime = new Date().toLocaleTimeString('en-GB', { hour12: false }).slice(0, 5); // HH:MM

    console.log('Current time:', currentTime);

    const medicationsToNotify = medications.flatMap((medication) => {
      const timings = JSON.parse(medication.timings);
      return timings
        .filter((timing) => timing <= currentTime)
        .map((timing) => ({
          ...medication,
          timing,
        }));
    });

    for (const { doctor_id, timing, medicine_name } of medicationsToNotify) {
      // Check if notification already sent
      const checkNotificationQuery = `
        SELECT COUNT(*) AS count
        FROM notifications
        WHERE reciver_id = ?
          AND medication_time = ?
          AND typeofnotifications LIKE ?
          AND DATE(created_at) = CURDATE()
      `;
      const message = `Reminder: It's time to take your medication: ${medicine_name}`;
      const result = await db.query(checkNotificationQuery, [receiverId, timing, `%${medicine_name}%`]);
      const rows = Array.isArray(result) ? result[0] : result;
      const notificationSent = rows.count > 0;

      if (!notificationSent) {
        // Insert notification (only insert the date part of current time)
        const notificationQuery = `
        INSERT IGNORE INTO notifications (Sender_id, reciver_id, typeofnotifications, is_read, medication_time, created_at)
        VALUES (?, ?, ?, 0, ?, ?)
        `;
        await db.query(notificationQuery, [doctor_id, receiverId, message, timing, currentDate]);
        console.log(`Notification sent for medication: ${medicine_name}, timing: ${timing}`);
      }
    }

    return res.status(200).json({
      message: "Medications reminders fetched successfully",
    });
  } catch (error) {
    console.error('Error fetching medication reminders: ', error);
    return res.status(500).json({
      error: "An error occurred while fetching medication reminders",
    });
  }
};


  module.exports = { getMedications,
    getAllMedicationsForPatient,
    createNewMedication,
    getMedicationsForPatientById,
    getUserEmailByToken,
    deleteMedicationById,
    fetchMedicationsReminder
  };