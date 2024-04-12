const mongoose = require("mongoose");

const usersChatGroupSchema = new mongoose.Schema({
    _id: mongoose.Schema.Types.ObjectId,
    user_id: { type: String, ref: "Users", default: null },
    users: [{ type: String, ref: "Users" }],
    created_at: { type: Date, default: Date.now },
    updated_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model("UsersChatGroup", usersChatGroupSchema);