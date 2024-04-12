const mongoose = require("mongoose");

const legalService = new mongoose.Schema({
    _id: mongoose.Schema.Types.ObjectId,
    user: { type: String, ref: "Users" },
    handler: [{ type: String, ref: "Users" }], //for dev only
    updates: [{ type: String, ref: "legalServiceUpdates" }],
    type: { type: String, ref: "ServiceTypes" },
    location: { type: Object, default: null },
    applicant_details: [{ type: String, ref: "directors" }],
    objective: { type: String, default: null },
    capital: { type: Object, default: null }, //it will be paidup capital, Raised captal and contribution
    preferred_company_names: [{ type: String }],
    order: { type: String, ref: "Orders" },
    payment_status: { type: String, default: "unpaid" },
    status: { type: String, default: 'incomplete' },
    address_proof: [{ type: Object, default: null }],
    created_at: { type: Date, default: Date.now },
    updated_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model("BusinessRegistration", legalService);