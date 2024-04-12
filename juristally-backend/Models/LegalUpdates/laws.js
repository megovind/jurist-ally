const mongoose = require("mongoose");

const lawsSchema = new mongoose.Schema({
    _id: mongoose.Schema.Types.ObjectId,
    law_name: { type: String, default: null, required: true },
    lang: { type: String, default: "en" },
    created_at: { type: Date, default: Date.now },
    updated_at: { type: Date, default: Date.now }
});
// lawsSchema.index({ law_name: 'text' });
module.exports = mongoose.model("Laws", lawsSchema);