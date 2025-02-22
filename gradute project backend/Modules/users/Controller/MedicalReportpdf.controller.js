const pdfService = require('../service/MedicalReportpdf.service');
const pdfParse = require('pdf-parse');
const fs = require('fs');

const uploadPdf = async (req, res) => {
    try {
        // Access the userId from the request object (set by the authentication middleware)
        const userId = req.user.id;
        const file = req.file;

        if (!file || !userId) {
            return res.status(400).json({ message: 'File and User ID are required' });
        }

        // Extract text from the uploaded PDF file
        const extractedText = await extractTextFromPdf(file.path);

        // Call the service to handle the file processing and database updates
        const result = await pdfService.processPdfUpload(file, userId, extractedText);

        return res.status(200).json({ message: 'File uploaded successfully', data: result });
    } catch (error) {
        console.error('Error uploading file:', error);
        return res.status(500).json({ message: 'Internal Server Error' });
    }
};

const extractTextFromPdf = async (filePath) => {
    const dataBuffer = fs.readFileSync(filePath);
    const data = await pdfParse(dataBuffer);
    return data.text; // This is the extracted text from the PDF
};

const getUserFiles = async (req, res) => {
    try {
        const userId = req.user.id; // Get the user ID from the authentication token

        // Call the service to get the user's files
        const files = await pdfService.getUserFiles(userId);

        // If no files found, return a 404 error response
        if (files.length === 0) {
            return res.status(404).json({ message: 'No files found for this user.' });
        }

        // Return the files in the response
        return res.status(200).json({ files });
    } catch (error) {
        console.error(error);
        return res.status(500).json({ message: 'Server error.' });
    }
};





const deleteUserFile = async (req, res) => {
    try {
        const userId = req.user.id; // Get the authenticated user's ID
        const fileManagerId = req.params.id; // Get the file ID from the request URL

        // Call the service to delete the file
        const result = await pdfService.deleteFile(fileManagerId, userId);

        if (result.success) {
            return res.status(200).json({ message: 'File deleted successfully' });
        } else {
            return res.status(404).json({ message: 'File not found or unauthorized' });
        }
    } catch (error) {
        console.error('Error deleting file:', error);
        return res.status(500).json({ message: 'Internal Server Error' });
    }
};

const getFilesByUserId = async (req, res) => {
    try {
        // Get the user ID from the URL parameter (req.params.id)
        const userId = req.params.id;

        if (!userId) {
            return res.status(400).json({ message: 'User ID is required' });
        }

        // Call the service to get the files for the provided user ID
        const files = await pdfService.getFilesByUserId(userId);

        // If no files found, return a 404 error response
        if (files.length === 0) {
            return res.status(404).json({ message: 'No files found for this user.' });
        }

        // Return the files in the response
        return res.status(200).json({ files });
    } catch (error) {
        console.error(error);
        return res.status(500).json({ message: 'Server error.' });
    }
};

module.exports = { uploadPdf, getUserFiles,deleteUserFile,getFilesByUserId };
