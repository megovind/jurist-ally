const mongoose = require("mongoose");

const itrGstFillingsService = new mongoose.Schema({
    _id: mongoose.Schema.Types.ObjectId,
    user: { type: String, ref: "Users" },
    handler: [{ type: String, ref: "Users" }], //for dev only
    type: { type: String, ref: "ServiceTypes" },
    updates: [{ type: String, ref: "legalServiceUpdates" }],
    name: { type: String, required: true },
    contact_number: { type: String, required: true },
    email: { type: String, required: true },
    is_nil: { type: Boolean, default: false },
    f_year: { type: String, required: true },
    location: { type: Object, default: null },
    filling_month_year: { type: String, default: null },
    gst_number: { type: String, default: null },
    photograph: { type: Object, default: null },
    pan_card: { type: Object, default: null },
    aadhar_voter_card: { type: Object, default: null },
    passport_bank_statement: { type: Object, default: null },
    gst_certificate: { type: Object, default: null },
    invoices: [{ type: Object }],
    is_aadhar_phone_linked: { type: Boolean, default: true },
    status: { type: String, default: 'incomplete' },
    order: { type: String, ref: "Orders" },
    payment_status: { type: String, default: "unpaid" },
    created_at: { type: Date, default: Date.now },
    updated_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model("ItrGstFillings", itrGstFillingsService);