const mongoose = require("mongoose");

const serviceTypes = new mongoose.Schema({
    _id: mongoose.Schema.Types.ObjectId,
    title: { type: String, default: null },
    description: { type: String, default: null },
    category: { type: String, default: null },
    price: { type: Number, default: null },
    min_dir: { type: Number, default: 0 },
    max_dir: { type: Number, default: 0 },
    created_at: { type: Date, default: Date.now },
    updated_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model("ServiceTypes", serviceTypes);