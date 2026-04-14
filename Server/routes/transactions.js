const express = require('express');
const router = express.Router();
const Transaction = require('../models/Transaction');
const { parseInput } = require('../utils/ai_parser');

// Get all transactions for a user
router.get('/:userId', async (req, res) => {
  try {
    const transactions = await Transaction.find({ userId: req.params.userId }).sort({ date: -1 });
    res.json(transactions);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Add manual transaction
router.post('/', async (req, res) => {
  try {
    const transaction = new Transaction(req.body);
    await transaction.save();
    res.status(201).json(transaction);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// AI Smart Log
router.post('/smart', async (req, res) => {
  try {
    const { userId, rawInput } = req.body;
    const parsedData = parseInput(rawInput);
    
    const transaction = new Transaction({
      userId,
      ...parsedData,
      rawInput
    });
    
    await transaction.save();
    res.status(201).json(transaction);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
