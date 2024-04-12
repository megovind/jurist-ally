const mongoose = require("mongoose");

const legalServiceUpdate = new mongoose.Schema({
    step: { type: Number, default: 0 },
    step_text: { type: String, default: null },
    service: { type: String, default: null },
    status: { type: String, default: null },
    handler_message: { type: String, default: null },
    applicant_message: { type: String, default: null },
    files: [{ type: Object }],
    percentage: { type: Number, default: 0 },
    created_at: { type: Date, default: Date.now },
    updated_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model("legalServiceUpdates", legalServiceUpdate);