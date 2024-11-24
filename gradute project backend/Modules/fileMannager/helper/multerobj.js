const multer = require('multer');

// Configure storage for both photos and audio
const filestorage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, './public/Uploade'); // Ensure this directory exists
    },
    filename: (req, file, cb) => {
        // Use the original file name and append the current timestamp
        const fileExtension = file.originalname.split('.').pop().toLowerCase();
        let filename = `${file.originalname.split('.')[0]}-${Date.now()}.${fileExtension}`;
        cb(null, filename);
    }
});

// Create the Multer upload middleware
const Uploade = multer({ storage: filestorage });

// Export the upload middleware
module.exports = Uploade;
