const mongoose = require("mongoose");

const notiticationsSchema = new mongoose.Schema({
    _id: mongoose.Schema.Types.ObjectId,
    user: { type: String, ref: 'Users' },
    title: { type: String, default: null },
    notification: { type: String, required: true },
    status: { type: String, default: 'open' },
    created_at: { type: Date, default: Date.now },
    created_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model("Notifications", notiticationsSchema);
