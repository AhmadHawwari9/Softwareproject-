const userService = require('../service/Operationsonusersfortheadmin.service');

const getUsers = async (req, res) => {
    try {
        const users = await userService.getUsersExceptAdmin(); 
        res.json(users); 
    } catch (error) {
        console.error('Error fetching users:', error); 
        res.status(500).json({
            message: 'Error fetching users',
            error: error.message || 'Unexpected error occurred',
        });
    }
};

const deleteUser = async (req, res) => {
    const { id } = req.params;
  
    try {
      const result = await userService.deleteUserById(id);
  
      if (result.affectedRows > 0) {
        res.status(200).json({ message: 'User deleted successfully' });
      } else {
        res.status(404).json({ message: 'User not found' });
      }
    } catch (error) {
      console.error('Error deleting user:', error);
      res.status(500).json({
        message: 'Error deleting user',
        error: error.message || 'Unexpected error occurred',
      });
    }
  };

module.exports = { getUsers,deleteUser };
