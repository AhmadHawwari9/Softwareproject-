const { validationResult } = require("express-validator");
const { createUser } = require("../service/users.service");
const jwt = require("jsonwebtoken");
const filemannager = require('../../fileMannager/services/FileMannager.service');

const createUsersUsingPost = async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(422).json({ errors: errors.array() });
  }

  const file = req.file;
  console.log(file);

  try {
    // Handle file creation and get the image ID
    const imgid = await filemannager.filecreate(file);

    // Extract user details from the request body
    const { first_name, last_name, email, age, password, typeofuser } = req.body;

    // Create the user in the database
    const { userId } = await createUser(first_name, last_name, email, age, password, typeofuser, imgid);

    // Generate a JWT token after user creation
    const accesstoken = jwt.sign({ id: userId, email }, 'Course', { expiresIn: '30d' });


    console.log('Request headers:', req.headers);

    // Respond with a success message and the token
    return res.status(201).json({
      message: "User created successfully",
      userId: userId,
      accessToken: accesstoken, // Send the token back to the client
    });
  } catch (error) {
    console.error('Error creating user: ', error); // Log the error for debugging
    return res.status(500).json({
      error: "An error occurred while creating the user",
    });
  }
};

module.exports = {
  createUsersUsingPost,
};
