const { validationResult } = require("express-validator");
const { login } = require("../service/login.service");

const createUsersUsingPostLogin = async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(422).send({
            errors: errors.array()
        });
    }

    const { email, password } = req.body;

    try {
        const result = await login(email, password);
        return res.status(200).json(result); // Return the successful response
    } catch (error) {
        return res.status(401).json({ error: error.error }); // Handle login errors
    }
};

module.exports = {
    createUsersUsingPostLogin
};
