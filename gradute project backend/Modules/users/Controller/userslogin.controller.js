const { validationResult } = require("express-validator");
const { login } = require("../service/login.service");
const jwt = require("jsonwebtoken");

const createUsersUsingPostLogin = async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(422).send({ errors: errors.array() });
    }

    const { email, password } = req.body;
    try {
        const result = await login(email, password);

        // Create access token
        const accesstoken = jwt.sign({ id: result.userId, email: result.email }, 'Course', { expiresIn: '30d' });

        // Log the generated token for debugging
        console.log('Generated Access Token:', accesstoken);

        // Return the response with userId and email
        return res.status(200).json({
            result: {
                message: 'Login successful',
                userId: result.userId,  // Ensure userId is included here
                email: result.email
            },
            accesstoken: accesstoken
        });
    } catch (err) {
        console.error('Login error:', err); // Log error for debugging
        return res.status(401).json({
            result: { error: err.error || 'Login failed' }
        });
    }
};

module.exports = {
    createUsersUsingPostLogin
};
