const userService = require('../service/Profile.Service');

const getUserProfile = async (req, res) => {
  try {
    const userId = req.user.id; // This comes from the JWT middleware
    const userData = await userService.getUserDataById(userId);

    if (!userData) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json(userData);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

const updateUserBio = async (req, res) => {
    const userId = req.user.id; // Extracted from the authentication middleware
    const { bio } = req.body; // New bio from request body
  
    if (!bio || bio.trim() === '') {
      return res.status(400).json({ message: 'Bio cannot be empty.' });
    }
  
    try {
      const result = await userService.updateBio(userId, bio);
      if (result.affectedRows > 0) {
        res.status(200).json({ message: 'Bio updated successfully.' });
      } else {
        res.status(404).json({ message: 'User not found.' });
      }
    } catch (error) {
      console.error('Error updating bio:', error);
      res.status(500).json({ message: 'An error occurred while updating the bio.' });
    }
  };

  const updateUserage = async (req, res) => {
    const userId = req.user.id; 
    const { age } = req.body; 
  
    if (!age || age.trim() === '') {
      return res.status(400).json({ message: 'age cannot be empty.' });
    }
  
    try {
      const result = await userService.updateage(userId, age);
      if (result.affectedRows > 0) {
        res.status(200).json({ message: 'age updated successfully.' });
      } else {
        res.status(404).json({ message: 'User not found.' });
      }
    } catch (error) {
      console.error('Error updating age:', error);
      res.status(500).json({ message: 'An error occurred while updating the age.' });
    }
  };

  const updateImageForUser = async (req, res) => {
    const user_id = req.user.id; // Extracted from authentication middleware
    const { file } = req; // Multer automatically saves the file as 'file' or 'photo' field
    
    // Validate if a file is uploaded
    if (!file) {
      return res.status(400).json({ message: 'New image file is required' });
    }
  
    try {
      // Call the service to update the image
      const result = await userService.updateImage(user_id, file); // Pass the file to the service
      
      if (result.message) {
        return res.status(200).json({ message: result.message, file_id: result.file_id });
      } else {
        return res.status(404).json({ message: 'Image update failed' });
      }
    } catch (err) {
      console.error('Error updating image:', err);
      return res.status(500).json({ message: 'Server error', error: err.message });
    }
  };
  
  

  
module.exports = { getUserProfile , updateUserBio,updateUserage,updateImageForUser};
 