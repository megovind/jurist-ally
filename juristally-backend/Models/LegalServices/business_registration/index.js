const mongoose = require("mongoose");

const legalService = new mongoose.Schema({
    _id: mongoose.Schema.Types.ObjectId,
    user: { type: String, ref: "Users" },
    handler: [{ type: String, ref: "Users" }], //for dev only
    type: { type: String, ref: "ServiceTypes" },
    location: { type: Object, default: null },
    applicant_details: [{ type: String, ref: "directors" }],
    address_proof: { type: Object, default: null },
    objective: { type: String, default: null },
    capital: { type: Object, default: null }, //it will be paidup capital, Raised captal and contribution
    preferred_company_names: [{ type: String }],
    status: { type: String, default: 'incomplete' },
    updates: [{ type: String, ref: "legalServiceUpdates" }],
    order: { type: String, ref: "Orders" },
    payment_status: { type: String, default: "unpaid" },
    token: { type: Boolean, default: false },
    invoices: [{ type: Object }],
    is_nil: { type: Boolean, default: false },
    f_year: { type: String, default: null },
    month_year: { type: String, default: null },
    gst_number: { type: String, default: null },
    created_at: { type: Date, default: Date.now },
    updated_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model("Legalservices", legalService);