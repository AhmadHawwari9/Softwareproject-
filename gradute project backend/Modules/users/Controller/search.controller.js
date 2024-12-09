const { getAllUsersExcept, getUserByIdFromDb } = require('../service/search.service');

const getUsersfromsearch = async (req, res) => {
  try {
    const loggedInUserId = req.user.id; 
    const users = await getAllUsersExcept(loggedInUserId); 

    res.status(200).json({
      success: true,
      data: users,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch users',
      error: error.message,
    });
  }
};


const getUserById = async (req, res) => {
  const { id } = req.params;

  try {
    const user = await getUserByIdFromDb(id);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }
    res.status(200).json({
      success: true,
      data: user,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch user',
      error: error.message,
    });
  }
};

module.exports = {
  getUsersfromsearch,
  getUserById,
};
