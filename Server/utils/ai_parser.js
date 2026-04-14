/**
 * a simple but effective rule-based parser that mimics AI logic 
 * for smart expense logging. In production, this would call 
 * an LLM like GPT-4 or Gemini.
 */

const categories = {
  'Food & Dining': ['lunch', 'dinner', 'breakfast', 'restaurant', 'cafe', 'food', 'pizza', 'burger', 'swiggy', 'zomato'],
  'Transport': ['uber', 'ola', 'taxi', 'petrol', 'diesel', 'fuel', 'metro', 'train', 'bus', 'travel'],
  'Shopping': ['amazon', 'flipkart', 'myntra', 'clothes', 'shoes', 'mall', 'shopping'],
  'Entertainment': ['netflix', 'movie', 'cinema', 'game', 'playstation', 'concert', 'party'],
  'Bills': ['electricity', 'water', 'internet', 'recharge', 'rent', 'bill'],
  'Salary': ['salary', 'bonus', 'paycheck', 'income'],
};

const symbols = {
  'Food & Dining': 'utensils',
  'Transport': 'plane',
  'Shopping': 'shopping-bag',
  'Entertainment': 'zap',
  'Bills': 'briefcase',
  'Salary': 'banknote',
};

const colors = {
  'Food & Dining': ['#FF9A8B', '#FF6A88'],
  'Transport': ['#74EBD5', '#9FACE6'],
  'Shopping': ['#F6D365', '#FDA085'],
  'Entertainment': ['#A18CD1', '#FBC2EB'],
  'Bills': ['#84FAB0', '#8FD3F4'],
  'Salary': ['#FFECD2', '#FCB69F'],
};

exports.parseInput = (input) => {
  const text = input.toLowerCase();
  
  // Extract amount
  const amountMatch = text.match(/(?:₹|rs\.?|inr|amount|spent|received)?\s?(\d+(?:,\d+)*(?:\.\d+)?)/i);
  const amount = amountMatch ? parseFloat(amountMatch[1].replace(/,/g, '')) : 0;

  // Determine Kind
  let kind = 'expense';
  if (text.includes('received') || text.includes('income') || text.includes('salary') || text.includes('bonus')) {
    kind = 'income';
  }

  // Determine Category
  let categoryTitle = kind === 'income' ? 'Salary' : 'Shopping'; // Default
  for (const [cat, keywords] of Object.entries(categories)) {
    if (keywords.some(keyword => text.includes(keyword))) {
      categoryTitle = cat;
      break;
    }
  }

  return {
    kind,
    amount,
    categoryTitle,
    categorySymbol: symbols[categoryTitle],
    categoryColors: colors[categoryTitle],
    note: input,
    isSmartLogged: true
  };
};
