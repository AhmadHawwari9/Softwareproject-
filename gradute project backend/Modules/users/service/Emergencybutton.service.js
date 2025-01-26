const db = require('../../../db/database');

const getCaregiversByCareRecipientId = (careRecipientId) => {
    return new Promise((resolve, reject) => {
      const query = `
        SELECT 
          c.Care_giverid,
          c.carerecipient_id
        FROM carerecipientlist c
        WHERE c.carerecipient_id = ?;
      `;
  
      db.query(query, [careRecipientId], (err, results) => {
        if (err) {
          return reject(err);
        }
        resolve(results); // Return all matching caregivers
      });
    });
  };
  
  const sendNotifications = async (patientId, caregivers, latitude, longitude) => {
    try {
      for (const caregiver of caregivers) {
        // Concatenate coordinates into the notification message
        const notificationMessage = `Emergency Alert: Lat=${latitude}, Lng=${longitude}`;
  
        const notification = {
          Sender_id: patientId,
          reciver_id: caregiver.Care_giverid,
          typeofnotifications: notificationMessage, // Include coordinates in the message
          is_read: 0,
        };
  
        const query = `
          INSERT INTO notifications (Sender_id, reciver_id, typeofnotifications, is_read)
          VALUES (?, ?, ?, ?);
        `;
  
        await db.query(query, [
          notification.Sender_id,
          notification.reciver_id,
          notification.typeofnotifications,
          notification.is_read,
        ]);
      }
    } catch (error) {
      console.error('Error sending notifications:', error);
      throw error;
    }
  };
  

  

  const deleteExistingPatientDoctors = (patientId) => {
    return new Promise((resolve, reject) => {
      const query = `DELETE FROM patient_doctors WHERE patient_id = ?;`;
  
      db.query(query, [patientId], (err, results) => {
        if (err) {
          return reject(err);
        }
        resolve(results);
      });
    });
  };
  
  const addPatientDoctors = (patientId, doctorsIds) => {
    return new Promise((resolve, reject) => {
      const query = `
        INSERT INTO patient_doctors (patient_id, doctors_ids)
        VALUES (?, ?);
      `;
  
      // Convert doctorsIds array to JSON format
      const doctorsIdsJson = JSON.stringify(doctorsIds);
  
      db.query(query, [patientId, doctorsIdsJson], (err, results) => {
        if (err) {
          return reject(err);
        }
        resolve(results);
      });
    });
  };
  

  const getCaregiversByDoctorIds = (doctorsIds) => {
    return new Promise((resolve, reject) => {
      const query = `
        SELECT Care_giverid, carerecipient_id
        FROM carerecipientlist
        WHERE Care_giverid IN (?);
      `;
  
      db.query(query, [doctorsIds], (err, results) => {
        if (err) {
          return reject(err);
        }
        resolve(results); // Return caregivers whose IDs are in the doctors_ids array
      });
    });
  };

  const getDoctorsIds = (patientId) => {
    return new Promise((resolve, reject) => {
      const query = `
        SELECT doctors_ids 
        FROM patient_doctors 
        WHERE patient_id = ?;
      `;
      
      db.query(query, [patientId], (err, results) => {
        if (err) {
          return reject(err);
        }
        
        if (results.length === 0) {
          return resolve([]); // Return an empty array if no data is found
        }
  
        // Parse the doctors_ids JSON string into an array
        const doctorsIds = JSON.parse(results[0].doctors_ids);
        resolve(doctorsIds);
      });
    });
  };
  
  const getDoctorsEmails = (doctorsIds) => {
    return new Promise((resolve, reject) => {
      const query = `
        SELECT Email
        FROM users
        WHERE User_id IN (?);
      `;
  
      // Use the `IN` clause with a list of doctor IDs
      db.query(query, [doctorsIds], (err, results) => {
        if (err) {
          return reject(err);
        }
  
        // Extract the emails from the result
        const emails = results.map(user => user.Email);
        resolve(emails);
      });
    });
  };
  
  

  module.exports={
    getCaregiversByCareRecipientId,
    sendNotifications,
    addPatientDoctors,
    deleteExistingPatientDoctors,
    getDoctorsEmails,
    getDoctorsIds,
    getCaregiversByDoctorIds
  }