const mongoose = require("mongoose");

const postsSchema = new mongoose.Schema({
    _id: mongoose.Schema.Types.ObjectId,
    user: { type: String, ref: "Users" },
    content: { type: String, default: null },
    media: { type: Object },
    likes: [{ type: String, ref: "Users" }],
    comments: [{ type: String, ref: "Comments" }],
    shared_with: [{ type: String, ref: "Users" }],
    created_at: { type: Date, default: Date.now },
    updated_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model("Posts", postsSchema);
