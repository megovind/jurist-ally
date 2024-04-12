const mongoose = require("mongoose");

var ChatMessagesSchema = new mongoose.Schema({
    _id: mongoose.Schema.Types.ObjectId,
    messages: [
        {
            media: [{ type: String, default: null }],
            message: { type: String, default: null },
            from: { type: String, default: null, ref: "Users" },
            to: { type: String, default: null, ref: "Users" },
            timestamp: { type: Date, default: Date.now },
        }
    ],
    is_group_message: { type: Boolean, default: false },
    participants: [
        {
            user: {
                type: mongoose.Schema.Types.ObjectId,
                ref: 'User'
            },
            delivered: { type: Boolean, default: false },
            read: { type: Boolean, default: false },
            last_seen: { type: Date, default: Date.now }
        }
    ]
});

module.exports = mongoose.model("ChatMessages", ChatMessagesSchema);