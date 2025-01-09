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
        uf.path AS user_image_path,  -- This will return the image path of the user from filemanager
        u.Email AS user_email
      FROM hospitals h
      LEFT JOIN users u ON u.User_id = h.user_id  -- Join to get user data
      LEFT JOIN filemannager uf ON u.image_id = uf.file_id;  -- Join to get user image path
    `;
    
    db.query(query, (err, results) => {
      if (err) {
        return reject(err);
      }
      resolve(results);
    });
  });
};

  
  
  const getHospitalWithImagePathByUserId = (userId) => {
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
        LEFT JOIN users u ON u.User_id = h.User_id
        WHERE h.User_id = ?;
      `;
  
      db.query(query, [userId], (err, results) => {
        if (err) {
          return reject(err);
        }
        resolve(results[0]); // Return the first matching record.
      });
    });
  };


const getHospitalByUserId = (User_id) => {
  return new Promise((resolve, reject) => {
    const query = 'SELECT * FROM hospitals WHERE User_id = ?';
    db.query(query, [User_id], (err, results) => {
      if (err) return reject(err);
      resolve(results[0]); // Return the first record found
    });
  });
};

const deleteHospitalById = (id) => {
  return new Promise((resolve, reject) => {
    const query = 'DELETE FROM hospitals WHERE id = ?';
    db.query(query, [id], (err, results) => {
      if (err) return reject(err);
      resolve(results.affectedRows);
    });
  });
};

const addHospital = (hospitalData) => {
  const { User_id, name, image_id, location, description, clinics, workingHours, doctors, contact } = hospitalData;
  return new Promise((resolve, reject) => {
    const query = `
      INSERT INTO hospitals (User_id, name, image_id, location, description, clinics, workingHours, doctors, contact)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    `;
    db.query(query, [User_id, name, image_id, location, description, clinics, workingHours, doctors, contact], (err, results) => {
      if (err) return reject(err);
      resolve(results.insertId);
    });
  });
};

const uploadFile = (file) => {
  return new Promise((resolve, reject) => {
    const query = `
      INSERT INTO filemannager (old_name, new_name, folder, path)
      VALUES (?, ?, ?, ?)
    `;
    const newName = `${Date.now()}-${file.originalname}`;
    const folder = './public/Uploade';
    const path = `Uploade/${newName}`;

    db.query(query, [file.originalname, newName, folder, path], (err, results) => {
      if (err) return reject(err);
      resolve(results.insertId); // Return the file ID
    });
  });
};

const updateUserImage = (User_id, image_id) => {
  return new Promise((resolve, reject) => {
    const query = 'UPDATE users SET image_id = ? WHERE User_id = ?';
    db.query(query, [image_id, User_id], (err, results) => {
      if (err) return reject(err);
      resolve(results.affectedRows);
    });
  });
};
const updateCaregiverImage = (User_id, image_id) => {
  return new Promise((resolve, reject) => {
    const query = 'UPDATE caregiverrequesttoadmin SET image_id = ? WHERE User_id = ?';
    db.query(query, [image_id, User_id], (err, results) => {
      if (err) return reject(err);
      resolve(results.affectedRows);
    });
  });
};


module.exports = {
  getHospitalsWithImagePaths,
  getHospitalWithImagePathByUserId,
  addHospital,
  uploadFile,
  getHospitalByUserId,
  deleteHospitalById,
  updateUserImage,
  updateCaregiverImage
};