const db = require('../../../db/database');

const saveDoctorAvailability = (doctorId, days, startTime, endTime) => {
  return new Promise((resolve, reject) => {
    const selectQuery = `
      SELECT * FROM doctor_availability WHERE doctor_id = ?
    `;

    db.query(selectQuery, [doctorId], (err, results) => {
      if (err) {
        reject(err); 
        return;
      }

      if (results.length > 0) {
        const deleteQuery = `
          DELETE FROM doctor_availability WHERE doctor_id = ?
        `;

        db.query(deleteQuery, [doctorId], (err, deleteResults) => {
          if (err) {
            reject(err); 
            return;
          }

          insertAvailability();
        });
      } else {
        insertAvailability();
      }

      function insertAvailability() {
        const insertQuery = `
          INSERT INTO doctor_availability (doctor_id, days, start_time, end_time)
          VALUES (?, ?, ?, ?)
        `;

        db.query(insertQuery, [doctorId, days, startTime, endTime], (err, insertResults) => {
          if (err) {
            reject(err); 
            return;
          }
          resolve(insertResults);
        });
      }
    });
  });
};

const getDoctorAvailability = (doctorId) => {
    return new Promise((resolve, reject) => {
     
      const query = `
        SELECT days, start_time, end_time
        FROM doctor_availability
        WHERE doctor_id = ?
      `;
  
      db.query(query, [doctorId], (err, results) => {
        if (err) {
          reject(err); 
          return;
        }
  
        if (results.length === 0) {
          resolve(null); 
        } else {
          resolve(results); 
        }
      });
    });
  };

  const findAvailabilityByDoctorId = (doctorId) => {
    return new Promise((resolve, reject) => {
      const query = `
        SELECT days, start_time, end_time
        FROM doctor_availability
        WHERE doctor_id = ?
      `;
  
      db.query(query, [doctorId], (err, results) => {
        if (err) {
          reject(err);
          return;
        }
  
        if (results.length === 0) {
          resolve(null);
        } else {
          resolve(results);
        }
      });
    });
  };
  
module.exports = { saveDoctorAvailability,
    getDoctorAvailability,
    findAvailabilityByDoctorId
};
