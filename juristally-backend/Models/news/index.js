const mongoose = require("mongoose");

const newsSchema = new mongoose.Schema({
    _id: mongoose.Schema.Types.ObjectId,
    user: { type: String, required: true },
    heading: { type: String, required: true },
    description: { type: String, required: true },
    image: { type: String, default: null },
    link: { type: String, default: null },
    verified: { type: Boolean, default: false },
    law_area: [{ type: String, ref: "Laws" }],
    tags: [{ type: String }],
    created_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model("News", newsSchema);
