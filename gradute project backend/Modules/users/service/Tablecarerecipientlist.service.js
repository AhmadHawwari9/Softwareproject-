const db = require('../../../db/database');

const getCareRecipientsByCareGiverId = (careGiverId) => {
  return new Promise((resolve, reject) => {
    const query = `
      SELECT 
        carerecipientlist.carerecipient_id, 
        users.Email 
      FROM carerecipientlist 
      INNER JOIN users ON carerecipientlist.carerecipient_id = users.User_id 
      WHERE carerecipientlist.Care_giverid = ?
    `;

    db.query(query, [careGiverId], (err, results) => {
      if (err) {
        reject(err); // Reject with the error
        return;
      }
      resolve(results); // Resolve with the fetched data
    });
  });
};

module.exports = { getCareRecipientsByCareGiverId };
