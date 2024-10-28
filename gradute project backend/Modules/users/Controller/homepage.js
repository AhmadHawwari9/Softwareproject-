const homepagecontroller = async (req, res) => {
    res.json({
        message: 'Welcome to the Homepage!',
    });
  };


  module.exports={
    homepagecontroller
  }