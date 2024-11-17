const db = require('../../../db/database'); 
const fs=require('fs');


const filecreate = async (file) => {
    return new Promise((resolve, reject) => {
        // Construct the relative path for the database (remove public/ prefix)
        const relativePath = `Uploade/${file.filename}`;

        // Insert logic for adding file data to the database
        const query = 'INSERT INTO filemannager (old_name, new_name, folder, path) VALUES (?, ?, ?, ?)';
        const values = [file.originalname, file.filename, file.destination, relativePath];

        db.query(query, values, (error, results) => {
            if (error) {
                console.error('Error inserting file: ', error);
                return reject(error); // Reject with the error
            }
            resolve(results.insertId); // Return the inserted file ID
        });
    });
};


const filedelete = async (file_id) => {
    try {
        // Query to get the file path before deletion
        const selectQuery = 'SELECT path FROM filemannager WHERE fileid = ?';
        const [fileResults] = await db.query(selectQuery, [file_id]);

        if (fileResults.length === 0) {
            console.warn('No file found with the given ID:', file_id);
            return {
                message: 'No file found with the given ID'
            };
        }

        // Construct full path for deletion
        const filePath = `./public/${fileResults[0].path}`;

        const deleteQuery = 'DELETE FROM filemannager WHERE fileid = ?';
        const [results] = await db.query(deleteQuery, [file_id]);

        if (results.affectedRows > 0) {
            if (fs.existsSync(filePath)) {
                fs.unlinkSync(filePath);
                console.log('File deleted from filesystem:', filePath);
            } else {
                console.warn('File not found on filesystem:', filePath);
            }

            return {
                message: 'File deleted successfully',
                dbId: file_id
            };
        }
    } catch (error) {
        console.error('Error deleting file:', error);
        throw new Error('File deletion failed');
    }
};


module.exports = {
    filecreate,
    filedelete 
};
