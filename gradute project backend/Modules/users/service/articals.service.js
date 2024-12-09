const db = require('../../../db/database');

const getAllArticles = (callback) => {
    db.query('SELECT * FROM articles', (err, results) => {
      if (err) {
        return callback(err, null);
      }
      return callback(null, results, results.length);
    });
  };


  const deleteArticleById = (id, callback) => {
    const query = 'DELETE FROM articles WHERE id = ?';
  
    db.query(query, [id], (err, results) => {
      if (err) {
        return callback(err, null);
      }
      return callback(null, results);
    });
  };

  const addArticle = (articleData) => {
    const { title, content, image_path } = articleData;
    const createdAt = new Date();
  
    return new Promise((resolve, reject) => {
      const query = `INSERT INTO articles (title, content, image_path, created_at) VALUES (?, ?, ?, ?)`;
      db.query(query, [title, content, image_path, createdAt], (error, results) => {
        if (error) return reject(error);
        resolve(results.insertId); // Return the ID of the newly created article
      });
    });
  };
  
  const getFilePath = (fileId) => {
    return new Promise((resolve, reject) => {
      const query = 'SELECT path FROM filemannager WHERE file_id = ?';
      db.query(query, [fileId], (err, results) => {
        if (err) {
          return reject(err);
        }
  
        console.log('File path from database:', results);  // Log to check if file_path exists
        
        if (results.length === 0) {
          return reject(new Error('File not found'));
        }
  
        resolve(results[0].path);  // Ensure 'file_path' is correctly returned
      });
    });
  };
  
  
  
  module.exports = { getAllArticles,deleteArticleById,addArticle,getFilePath };