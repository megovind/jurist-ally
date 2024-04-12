const mongoose = require("mongoose");

const serviceCategory = new mongoose.Schema({
    _id: mongoose.Schema.Types.ObjectId,
    title: { type: String, default: null },
    description: { type: String, default: null },
    category: { type: String, default: null },
    types: [{ type: String, ref: "ServiceTypes" }],
    created_at: { type: Date, default: Date.now },
    updated_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model("ServiceCategory", serviceCategory);