const { validationResult } = require("express-validator");
const { signInWithGoogle } = require("../service/SignInwithGoogle.service");

const createUsersUsingGoogleSignIn = async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(422).send({
            errors: errors.array()
        });
    }

    const { email } = req.body; // Only need email for this function
    try {
        const result = await signInWithGoogle(email);
        return res.status(200).json({
            result: result,
            message: 'Email exists'
        });
    } catch (err) {
        return res.status(401).json({
            result: null,
            error: err.error // Return the error from service
        });
    }
};

module.exports = {
    createUsersUsingGoogleSignIn
};
