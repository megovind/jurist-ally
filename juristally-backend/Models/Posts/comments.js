const mongoose = require("mongoose");

const commentsSchema = new mongoose.Schema({
    _id: mongoose.Schema.Types.ObjectId,
    user: { type: Object, default: null },
    comment: { type: String, default: null },
    created_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model("Comments", commentsSchema);
