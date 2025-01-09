const { updateEmail,changeUserPassword,deleteUserById } = require('../service/Settings.service');
const bcrypt = require("bcrypt");
const { validationResult } = require("express-validator");

const updateEmailController = async (req, res) => {
    try {
        console.log("Authenticated User: ", req.user);  // Make sure this logs the authenticated user object
        const userId = req.user.id;
        const { newEmail } = req.body;

        if (!newEmail) {
            return res.status(400).json({ error: 'NewEmail is required' });
        }

        const result = await updateEmail(userId, newEmail);
        res.status(200).json({ message: result.message });
    } catch (error) {
        console.error('Error updating email:', error);
        res.status(500).json({ error: error.message });
    }
};

  
  const changePassword = async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(422).json({ errors: errors.array() });
    }
  
    const { newPassword } = req.body;
    const userId = req.user.id; 
  
    try {
      const saltRounds = 10;
      const hashedPassword = await bcrypt.hash(newPassword, saltRounds);
  
      const result = await changeUserPassword(userId, hashedPassword);
  
      
      return res.status(200).json({
        message: "Password updated successfully",
      });
    } catch (error) {
      console.error('Error updating password: ', error);
      return res.status(500).json({
        error: "An error occurred while updating the password",
      });
    }
  };

  const deletemyaccount = async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(422).json({ errors: errors.array() });
    }
  
    const userId = req.user.id; 
  
    try {
      const result = await deleteUserById(userId); 
  
      if (!result) {
        return res.status(404).json({ error: 'User not found' });
      }
  
      
      return res.status(200).json({ message: 'User deleted successfully' });
  
    } catch (error) {
      console.error('Error deleting user: ', error);
      return res.status(500).json({
        error: 'An error occurred while deleting the user',
      });
    }
  };
  



module.exports = { updateEmailController,changePassword,deletemyaccount };
