const db = require('../../../db/database');


const getMedications = (doctorId, patientId) => {
    return new Promise((resolve, reject) => {
      const query = `
        SELECT id, patient_id, doctor_id, medicine_name, dosage, timings, created_at
        FROM medication_schedule
        WHERE doctor_id = ? AND patient_id = ?
      `;
  
      db.query(query, [doctorId, patientId], (err, results) => {
        if (err) {
          reject(err); // Reject with the error if query fails
          return;
        }
  
        if (results.length === 0) {
          resolve([]); // Resolve with an empty array if no records found
        } else {
          resolve(results); // Resolve with the found medication schedule
        }
      });
    });
  };

  const fetchMedicationsForPatient = (patientId) => {
    return new Promise((resolve, reject) => {
      const query = `
        SELECT 
          ms.id, 
          ms.patient_id, 
          ms.doctor_id, 
          ms.medicine_name, 
          ms.dosage, 
          ms.timings, 
          ms.created_at,
          patient.Email AS patient_email,
          doctor.Email AS doctor_email
        FROM medication_schedule ms
        JOIN users patient ON ms.patient_id = patient.User_id
        JOIN users doctor ON ms.doctor_id = doctor.User_id
        WHERE ms.patient_id = ?
      `;
      
      db.query(query, [patientId], (err, results) => {
        if (err) {
          reject(err); // Reject with the error if the query fails
          return;
        }
        
        if (results.length === 0) {
          resolve([]); // Resolve with an empty array if no records found
        } else {
          resolve(results); // Resolve with the found medication schedule
        }
      });
    });
  };

  const createMedicationRecord = ({ patientId, doctorId, medicineName, dosage, timings }) => {
    return new Promise((resolve, reject) => {
      const query = `
        INSERT INTO medication_schedule (patient_id, doctor_id, medicine_name, dosage, timings)
        VALUES (?, ?, ?, ?, ?)
      `;
  
      db.query(
        query,
        [patientId, doctorId, medicineName, dosage, timings],
        (err, results) => {
          if (err) {
            reject(err); // Reject with the error if the query fails
            return;
          }
  
          resolve(results.insertId); // Resolve with the ID of the inserted row
        }
      );
    });
  };
  
  const getMedicationsByPatientId = (patientId) => {
    return new Promise((resolve, reject) => {
      const query = `
        SELECT 
          ms.id, 
          ms.patient_id, 
          ms.doctor_id, 
          ms.medicine_name, 
          ms.dosage, 
          ms.timings, 
          ms.created_at,
          patient.Email AS patient_email,
          doctor.Email AS doctor_email
        FROM medication_schedule ms
        JOIN users patient ON ms.patient_id = patient.User_id
        JOIN users doctor ON ms.doctor_id = doctor.User_id
        WHERE ms.patient_id = ?
      `;
      
      db.query(query, [patientId], (err, results) => {
        if (err) {
          reject(err); // Reject with the error if the query fails
          return;
        }
        
        if (results.length === 0) {
          resolve([]); // Resolve with an empty array if no records found
        } else {
          resolve(results); // Resolve with the found medication schedule
        }
      });
    });
  };

  const getUserEmailById = (userId) => {
    return new Promise((resolve, reject) => {
      const query = `
        SELECT Email 
        FROM users 
        WHERE User_id = ?
      `;
      
      db.query(query, [userId], (err, results) => {
        if (err) {
          reject(err); // Reject with error if query fails
          return;
        }
        
        if (results.length === 0) {
          resolve(null); // Resolve with null if no user found
        } else {
          resolve(results[0].Email); // Resolve with the email of the user
        }
      });
    });
  };
  
  const deleteMedicationById = (medicationId) => {
    return new Promise((resolve, reject) => {
      const query = `DELETE FROM medication_schedule WHERE id = ?`;
  
      db.query(query, [medicationId], (err, results) => {
        if (err) {
          reject(err); // Reject with the error if the query fails
          return;
        }
  
        resolve(results); // Resolve with the result of the deletion
      });
    });
  };
  
  const getMedicationsForUser = (userId) => {
    return new Promise((resolve, reject) => {
      const query = `
        SELECT 
          ms.id, 
          ms.patient_id, 
          ms.doctor_id, 
          ms.medicine_name, 
          ms.dosage, 
          ms.timings, 
          ms.created_at,
          patient.Email AS patient_email,
          doctor.Email AS doctor_email
        FROM medication_schedule ms
        JOIN users patient ON ms.patient_id = patient.User_id
        JOIN users doctor ON ms.doctor_id = doctor.User_id
        WHERE ms.patient_id = ?
      `;
      
      db.query(query, [userId], (err, results) => {
        if (err) {
          reject(err);  // Reject with error if the query fails
          return;
        }
        
        resolve(results);  // Resolve with the medication schedule results
      });
    });
  };
  
  
  
  
  module.exports = { getMedications,
    fetchMedicationsForPatient,
    createMedicationRecord,
    getMedicationsByPatientId,
    getUserEmailById,
    deleteMedicationById,
    getMedicationsForUser
   };