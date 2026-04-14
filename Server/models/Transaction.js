const mongoose = require('mongoose');

const TransactionSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  kind: {
    type: String,
    enum: ['income', 'expense'],
    required: true
  },
  amount: {
    type: Number,
    required: true
  },
  categoryTitle: {
    type: String,
    required: true
  },
  categorySymbol: String,
  categoryColors: [String],
  note: String,
  date: {
    type: Date,
    default: Date.now
  },
  isSmartLogged: {
    type: Boolean,
    default: false
  },
  rawInput: String // For AI auditing
}, { timestamps: true });

module.exports = mongoose.model('Transaction', TransactionSchema);
