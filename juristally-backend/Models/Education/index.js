const mongoose = require("mongoose");

const educationSchema = new mongoose.Schema({
    _id: mongoose.Schema.Types.ObjectId,
    type: { type: String, required: true },
    institute_name: { type: String, required: true },
    stream: { type: String, required: true },
    start_date: { type: Date, default: null },
    end_date: { type: Date, default: null },
    is_present: { type: Boolean, default: false },
    created_at: { type: Date, default: Date.now },
    updated_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model("Education", educationSchema);