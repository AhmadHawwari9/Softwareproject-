const articleService = require('../service/articals.service');
const {filecreate,filedelete}= require('../../fileMannager/services/FileMannager.service');


const getArticles = (req, res) => {
    articleService.getAllArticles((err, articles, count) => {
      if (err) {
        return res.status(500).json({ message: 'Error retrieving articles', error: err });
      }
      return res.status(200).json({
        count: count,  // Return the count of articles
        articles: articles // Return the list of articles
      });
    });
  };

  const deleteArticle = (req, res) => {
    const { id } = req.params;
  
    if (!id) {
      return res.status(400).json({ message: 'Article ID is required.' });
    }
  
    articleService.deleteArticleById(id, (err, result) => {
      if (err) {
        return res.status(500).json({ message: 'Error deleting the article', error: err });
      }
  
      if (result.affectedRows === 0) {
        return res.status(404).json({ message: 'Article not found' });
      }
  
      return res.status(200).json({ message: 'Article deleted successfully' });
    });
  };


  
  const addArticle = async (req, res) => {
    try {
      const { title, content } = req.body;
      const file = req.file;
  
      if (!title || !content) {
        return res.status(400).json({ message: 'Title and content are required.' });
      }
  
      if (!file) {
        return res.status(400).json({ message: 'Image file is required.' });
      }
  
      const newFileId = await filecreate(file);
  
      const filePath = await articleService.getFilePath(newFileId);
  
      const newArticleId = await articleService.addArticle({
        title,
        content,
        image_path: filePath,
      });
  
      res.status(200).json({
        message: 'Article created successfully!',
        articleId: newArticleId,
        filePath: filePath,
      });
    } catch (error) {
      console.error('Error adding article:', error);
      res.status(500).json({ message: 'Failed to create article.', error: error.message });
    }
  };
  
  
 
  
  
  module.exports = { getArticles ,deleteArticle,addArticle}; 