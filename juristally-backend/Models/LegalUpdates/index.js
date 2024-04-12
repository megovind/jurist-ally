const mongoose = require("mongoose");

const legalUpdatesSchema = new mongoose.Schema({
    _id: mongoose.Schema.Types.ObjectId,
    act_rule: { type: String, default: null, required: true },
    file: { type: String, default: null, required: true },
    passed_on: { type: Date, default: Date.now, required: true },
    reference: { type: String, default: null },
    reference_link: { type: String, default: null },
    lang: { type: String, default: "en" },
    created_at: { type: Date, default: Date.now },
    updated_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model("LegalUpdate", legalUpdatesSchema);