const mongoose = require("mongoose");

const addressSchema = new mongoose.Schema({
    _id: mongoose.Schema.Types.ObjectId,
    address: { type: String, required: true },
    type: { type: String, default: null },//full time part time or many
    state: { type: String, default: null },
    city: { type: String, default: null },
    country: { type: Boolean, default: false },
    created_at: { type: Date, default: Date.now },
    updated_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model("Address", addressSchema);