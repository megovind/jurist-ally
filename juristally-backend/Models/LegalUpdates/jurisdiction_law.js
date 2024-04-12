const mongoose = require("mongoose");

const jurisdictionLaw = new mongoose.Schema({
    _id: mongoose.Schema.Types.ObjectId,
    jurisdiction_law: { type: String, default: null, required: true },
    file: { type: String, default: null, required: true },
    year: { type: String, required: true },
    passed_on: { type: Date, default: Date.now },
    created_at: { type: Date, default: Date.now },
    updated_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model("JurisdictionLaws", jurisdictionLaw);