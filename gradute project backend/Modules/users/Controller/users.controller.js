const { validationResult } = require("express-validator");
const {createUser} = require("../service/users.service");

const createUsersUsingPost = async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(422).send({
        errors: errors.array()
      });
    }
  
    const { first_name, last_name, email, age, password, typeofuser } = req.body;
  
    try {
      const userId = await createUser(first_name, last_name, email, age, password, typeofuser);
      return res.status(201).json({
        message: 'User created successfully',
        userId: userId
      });
    } catch (error) {
      return res.status(500).json({ error: error });
    }
  };

module.exports ={
    createUsersUsingPost
}