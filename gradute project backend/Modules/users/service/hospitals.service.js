const db = require('../../../db/database');

const getHospitalsWithImagePaths = () => {
    return new Promise((resolve, reject) => {
      const query = `
        SELECT 
          h.id, 
          h.User_id,
          h.name, 
          h.location, 
          h.description, 
          h.clinics, 
          h.workingHours, 
          h.doctors, 
          h.contact, 
          f.path AS image_path, 
          u.Email AS user_email
        FROM hospitals h
        LEFT JOIN filemannager f ON h.image_id = f.file_id
        LEFT JOIN users u ON u.User_id = h.user_id;  -- Assuming 'user_id' is the foreign key in the hospitals table referencing the users table.
      `;
      
      db.query(query, (err, results) => {
        if (err) {
          return reject(err);
        }
        resolve(results);
      });
    });
  };
  
  

module.exports = {
  getHospitalsWithImagePaths,
};