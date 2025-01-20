const getUserIdByToken = (req, res) => {
    try {
      // Extract the user ID from the authenticated request
      const userId = req.user.id;
  
      // Respond with the user ID
      res.status(200).json({
        userId: userId,
      });
    } catch (error) {
      console.error('Error fetching user ID:', error);
      res.status(500).json({ message: 'Failed to retrieve user ID.', error: error.message });
    }
  };
  
  module.exports = { getUserIdByToken };
  