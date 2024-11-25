const db = require('../../../db/database');
const { filecreate } = require('../../fileMannager/services/FileMannager.service');

const processPdfUpload = async (file, userId) => {
    try {
        // Insert the file into the filemannager table
        const fileManagerId = await filecreate(file);

        // Link the file to the user in the mymedicalreports table
        const query = 'INSERT INTO mymedicalreports (user_id, filemannager_id) VALUES (?, ?)';
        const values = [userId, fileManagerId];

        await new Promise((resolve, reject) => {
            db.query(query, values, (error, results) => {
                if (error) {
                    console.error('Error inserting into mymedicalreports:', error);
                    return reject(error);
                }
                resolve(results);
            });
        });

        return { userId, fileManagerId };
    } catch (error) {
        console.error('Error processing PDF upload:', error);
        throw error;
    }
};


const getUserFiles = (userId) => {
    return new Promise(async (resolve, reject) => {
        try {
            // Step 1: Query to get the file manager IDs and paths for the user from the database
            const sqlReports = `
                SELECT f.file_id AS id, f.path 
                FROM mymedicalreports m
                JOIN filemannager f ON m.filemannager_id = f.file_id
                WHERE m.user_id = ?
            `;

            db.query(sqlReports, [userId], (err, result) => {
                if (err) {
                    console.error("Error fetching user files:", err);
                    return reject(err);
                }

                // If no files found, resolve with an empty array
                if (!result || result.length === 0) {
                    return resolve([]);
                }

                // Resolve with the array of files containing id and path
                resolve(result);
            });
        } catch (error) {
            console.error("Unexpected error in getUserFiles:", error);
            reject(new Error("Could not fetch user files"));
        }
    });
};


const deleteFile = async (fileManagerId, userId) => {
    try {
        // Check if the file belongs to the user
        const checkQuery = 'SELECT * FROM mymedicalreports WHERE filemannager_id = ? AND user_id = ?';
        const checkValues = [fileManagerId, userId];

        const fileOwnership = await new Promise((resolve, reject) => {
            db.query(checkQuery, checkValues, (err, results) => {
                if (err) return reject(err);
                resolve(results);
            });
        });

        if (fileOwnership.length === 0) {
            return { success: false }; // File does not exist or doesn't belong to the user
        }

        // Delete from `filemannager` and `mymedicalreports` tables
        const deleteReportQuery = 'DELETE FROM mymedicalreports WHERE filemannager_id = ? AND user_id = ?';
        const deleteFileQuery = 'DELETE FROM filemannager WHERE file_id = ?';

        await new Promise((resolve, reject) => {
            db.query(deleteReportQuery, [fileManagerId, userId], (err) => {
                if (err) return reject(err);
                resolve();
            });
        });

        await new Promise((resolve, reject) => {
            db.query(deleteFileQuery, [fileManagerId], (err) => {
                if (err) return reject(err);
                resolve();
            });
        });

        return { success: true };
    } catch (error) {
        console.error('Error deleting file:', error);
        throw error;
    }
};

module.exports = { getUserFiles, processPdfUpload, deleteFile };
