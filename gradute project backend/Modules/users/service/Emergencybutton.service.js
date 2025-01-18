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
  
  const sendNotifications = async (careRecipientId, caregivers, latitude, longitude) => {
    try {
      for (const caregiver of caregivers) {
        // Concatenate coordinates into the typeofnotifications column
        const notificationMessage = `Emergency Alert: Lat=${latitude}, Lng=${longitude}`;
  
        const notification = {
          Sender_id: careRecipientId,
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
  
  

  module.exports={
    getCaregiversByCareRecipientId,
    sendNotifications
  }