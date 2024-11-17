const multer = require("multer");

// Configure the storage for Multer
const filestorage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, './public/Uploade'); // Ensure this directory exists
    },
    filename: (req, file, cb) => {
        // Use the original file name and append the current timestamp
        cb(null, `${file.originalname.split('.')[0]}-${Date.now()}.${file.originalname.split('.').pop()}`);
    }
});

// Create the Multer upload middleware
const Uploade = multer({ storage: filestorage });

// Export the upload middleware
module.exports = Uploade;
