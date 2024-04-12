const mongoose = require('mongoose');

const ratingsSchema = new mongoose.Schema({
    _id: mongoose.Schema.Types.ObjectId,
    user: { type: String, ref: 'Users' },
    total_rating: { type: Number, default: 5 },
    given_rating: { type: Number, default: 0 },
    created_at: { type: Date, default: Date.now },
    updated_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model("Ratings", ratingsSchema);