const mongoose = require("mongoose");

const notificationTokensSchema = new mongoose.Schema({
    _id: mongoose.Schema.Types.ObjectId,
    user: { type: String, ref: 'Users' },
    platform: { type: String, required: true },
    token: { type: String, default: null, required: true },
    created_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model("NotificationTokens", notificationTokensSchema);
