const mongoose = require("mongoose");

const compliancesSchema = new mongoose.Schema({
    _id: mongoose.Schema.Types.ObjectId,
    law_area: { type: String, default: null },
    compliance_description: { type: String, default: null },
    pental: { type: String, default: null },
    challan: { type: String, default: null },
    status: { type: String, default: "complied" },
    last_date_of_filing: { type: Date, default: Date.now },
    passed_on: { type: Date, default: Date.now },
    created_at: { type: Date, default: Date.now },
    updated_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model("Compliances", compliancesSchema);