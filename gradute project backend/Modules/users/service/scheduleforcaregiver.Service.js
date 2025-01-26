const db = require('../../../db/database');

const getScheduleByUserId = (userId) => {
  return new Promise((resolve, reject) => {
    // First, get the schedule data for the user
    const querySchedule = 'SELECT * FROM schedule WHERE id = ?';

    db.query(querySchedule, [userId], (err, scheduleResults) => {
      if (err) {
        reject(err);
        return;
      }
      if (!scheduleResults || scheduleResults.length === 0) {
        reject('No schedule found for this user');
        return;
      }

      // If schedule data is found, resolve with the data
      resolve(scheduleResults);
    });
  });
};

const updateSchedule = (scedual_id, name, date, time, userId) => {
    console.log('Inputs:', { scedual_id, name, date, time, userId });

    return new Promise((resolve, reject) => {
      const query = `
        UPDATE schedule 
        SET Name = ?, Date = ?, Time = ? 
        WHERE scedual_id = ? AND id = ?
      `;
      const params = [name, date, time, scedual_id, userId];
  
      db.query(query, params, (err, results) => {
        if (err) {
          reject(err); // Reject with the error
          return;
        }
        if (!results || results.affectedRows === 0) {
          reject('No rows were updated.'); // Reject if no rows were updated
          return;
        }
  
        // Resolve with the updated schedule details
        resolve({ scedual_id, name, date, time });
      });
    });
  };


  const deleteSchedule = (scedual_id, userId) => {
    return new Promise((resolve, reject) => {
      const query = `
        DELETE FROM schedule
        WHERE scedual_id = ? AND id = ?
      `;
      const params = [scedual_id, userId];
  
      db.query(query, params, (err, results) => {
        if (err) {
          reject(err); // Reject with the error
          return;
        }
        if (results.affectedRows === 0) {
          reject('No schedule found to delete.'); // Reject if no rows were affected
          return;
        }
  
        // Resolve indicating successful deletion
        resolve(true);
      });
    });
  };
  

  const addSchedule = (name, date, time, userId) => {
    return new Promise((resolve, reject) => {
      const query = `
        INSERT INTO schedule (Name, Date, Time, id)
        VALUES (?, ?, ?, ?)
      `;
      const params = [name, date, time, userId];
  
      db.query(query, params, (err, results) => {
        if (err) {
          reject(err); // Reject with the error
          return;
        }
        if (results.affectedRows === 0) {
          reject('Failed to add new schedule.');
          return;
        }
  
        // Resolve with the newly added schedule
        resolve({
          scedual_id: results.insertId, // Get the ID of the new row
          name,
          date,
          time
        });
      });
    });
  };
  
  const getScheduleByUserIdAndDate = (userId, date) => {
    return new Promise((resolve, reject) => {
      const querySchedule = `
        SELECT * 
        FROM schedule 
        WHERE id = ?  -- This should refer to user ID
        AND Date = ?;
      `;
      
      console.log('Running query:', querySchedule, 'with parameters:', [userId, date]);
      
      db.query(querySchedule, [userId, date], (err, scheduleResults) => {
        if (err) {
          reject(err);
          return;
        }
        if (!scheduleResults || scheduleResults.length === 0) {
          reject('No schedules found for this user on the specified date');
          return;
        }
        resolve(scheduleResults);  
      });
    });
  };
  
  const getScheduleByUserIdAndDate1 = (userId, date) => {
    return new Promise((resolve, reject) => {
      const querySchedule = `
        SELECT * 
        FROM schedule 
        WHERE id = ?  -- Updated to match user_id in the schedule table
        AND date = ?;
      `;
      
      console.log('Running query:', querySchedule, 'with parameters:', [userId, date]);
      
      db.query(querySchedule, [userId, date], (err, scheduleResults) => {
        if (err) {
          reject(err);
          return;
        }
        if (!scheduleResults || scheduleResults.length === 0) {
          reject('No schedules found for this user on the specified date');
          return;
        }
        resolve(scheduleResults);  
      });
    });
  };
  
  
  const modifySchedule = (scheduleId, name, date, time, userId) => {
    console.log('Inputs:', { scheduleId, name, date, time, userId });
  
    return new Promise((resolve, reject) => {
      const query = `
        UPDATE schedule 
        SET Name = ?, Date = ?, Time = ? 
        WHERE schedule_id = ? AND id = ?
      `;
      const params = [name, date, time, scheduleId, userId];
  
      db.query(query, params, (err, results) => {
        if (err) {
          reject(err); // Reject with the error
          return;
        }
        if (!results || results.affectedRows === 0) {
          reject('No rows were updated.'); // Reject if no rows were updated
          return;
        }
  
        // Resolve with the updated schedule details
        resolve({ scheduleId, name, date, time });
      });
    });
  };
  

  const removeSchedule = (scheduleId, userId) => {
    return new Promise((resolve, reject) => {
        const query = `
            DELETE FROM schedule
            WHERE scedual_id = ? AND id = ?
        `;
        const params = [scheduleId, userId];

        db.query(query, params, (err, results) => {
            if (err) {
                reject(err); // Reject with the error
                return;
            }
            if (results.affectedRows === 0) {
                reject('No schedule found to remove.'); // Reject if no rows were affected
                return;
            }

            // Resolve indicating successful removal
            resolve(true);
        });
    });
};


const caregiverScheduleService = {
  getScheduleByUserId: (userId) => {
    return new Promise((resolve, reject) => {
      // Query to fetch the schedule for the caregiver
      const querySchedule = 'SELECT * FROM schedule WHERE id = ?';

      db.query(querySchedule, [userId], (err, scheduleResults) => {
        if (err) {
          reject(err);
          return;
        }
        if (!scheduleResults || scheduleResults.length === 0) {
          reject('No schedule found for this caregiver');
          return;
        }

        // Resolve with the schedule data
        resolve(scheduleResults);
      });
    });
  },
};

const addScheduleById = (name, date, time, userId) => {
  return new Promise((resolve, reject) => {
    const query = `
      INSERT INTO schedule (Name, Date, Time, id)
      VALUES (?, ?, ?, ?)
    `;
    const params = [name, date, time, userId];

    db.query(query, params, (err, results) => {
      if (err) {
        reject(err);
        return;
      }
      if (results.affectedRows === 0) {
        reject('Failed to add new schedule.');
        return;
      }

      resolve({
        schedule_id: results.insertId,
        name,
        date,
        time,
      });
    });
  });
};

const getUserById = (userId) => {
  return new Promise((resolve, reject) => {
    const query = 'SELECT First_name, Last_name FROM users WHERE User_id = ?';
    db.query(query, [userId], (err, results) => {
      if (err) {
        reject(err);
        return;
      }
      if (results.length === 0) {
        resolve(null); // No user found
        return;
      }
      resolve(results[0]); // Return the user's details
    });
  });
};

module.exports = {getScheduleByUserId,updateSchedule,deleteSchedule,addSchedule,getScheduleByUserIdAndDate,getScheduleByUserIdAndDate1,
  modifySchedule,
  removeSchedule,
  caregiverScheduleService,
  addScheduleById,
  getUserById
};
