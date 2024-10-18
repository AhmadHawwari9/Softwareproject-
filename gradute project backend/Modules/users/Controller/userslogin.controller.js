const { validationResult } = require("express-validator");
const { login } = require("../service/login.service");
const jwt = require("jsonwebtoken");

const createUsersUsingPostLogin = async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(422).send({
            errors: errors.array()
        });
    }

    const { email, password } = req.body;
    const result = await login(email, password);
   
    if(result){
        const accesstoken=jwt.sign({result},'Course',{expiresIn:'30d'})
        return res.status(200).json({
            result:result,
            accesstoken:accesstoken
        });
    }

    return res.status(401).json({
        result:result
    });
    
};

module.exports = {
    createUsersUsingPostLogin
};
