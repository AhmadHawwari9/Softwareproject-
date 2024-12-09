const jwt = require("jsonwebtoken");

const authonitication = (req, res, next) => {
    // Get the Authorization header
    const authHeader = req.headers.authorization;

    // Extract the token from 'Bearer <token>'
    const token = authHeader && authHeader.split(' ')[1];

    if (token) {
        try {
            // Verify the token with the secret key ('Course')
            const user = jwt.verify(token, 'Course'); // Ensure the secret matches
            
            // Log the verified user object
            console.log('Token verified successfully:', user);
            
            // Attach the user object to the request object
            req.user = user;

            // Proceed to the next middleware or route handler
            next();
        } catch (err) {
            // Handle token verification errors, including token expiration
            console.error('Token verification failed:', err.message);
            
            return res.status(401).json({
                message: err.name === 'TokenExpiredError' ? 'Token has expired' : 'Invalid token'
            });
        }
    } else {
        // No token provided in the Authorization header
        console.error('Authorization header missing or token not provided');
        
        return res.status(401).json({
            message: 'Authorization token is missing'
        });
    }
};

module.exports = {
    authonitication
};
