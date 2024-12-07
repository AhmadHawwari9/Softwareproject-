const db = require('../../../db/database'); 

const getReportsForUser = async (userId) => {
  return new Promise((resolve, reject) => {

    const query = `
      SELECT Date, Heartrate, FastingBloodSugar, Haemoglobin, whitebloodcells, Bloodpressure, HDL, LDL
      FROM mymedicalreports
      WHERE user_id = ?
      ORDER BY Date DESC;`; // Change DESC to ASC if you want ascending order

    // Execute the query with the user ID
    db.query(query, [userId], (err, results) => {
      if (err) {
        return reject({ error: 'Database query error' });
      }
      if (results.length === 0) {
        return reject({ error: 'No medical reports found for this user' });
      }

      // Resolve with the fetched results
      resolve(results);
    });
  });
};

module.exports = { getReportsForUser };
