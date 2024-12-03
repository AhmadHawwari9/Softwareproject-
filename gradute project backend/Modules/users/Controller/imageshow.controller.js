const userService = require('../service/imageshow.service');

const getUserImagePath = async (req, res) => {
    try {
        const email = req.params.email;
        const imagePath = await userService.getUserImagePathByEmail(email);

        if (!imagePath) {
            return res.status(404).json({ message: 'User not found or image not available' });
        }

        res.json({ imagePath });
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};

module.exports = { getUserImagePath };
