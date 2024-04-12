const mongoose = require("mongoose");

const dscRegistrationService = new mongoose.Schema({
    _id: mongoose.Schema.Types.ObjectId,
    user: { type: String, ref: "Users" },
    handler: [{ type: String, ref: "Users" }], //for dev only
    updates: [{ type: String, ref: "legalServiceUpdates" }],
    type: { type: String, ref: "ServiceTypes" },
    name: { type: String, required: true },
    email: { type: String, required: true },
    contact_number: { type: Number, required: true },
    photograph: { type: Object, default: null },
    pan_card: { type: Object, default: null },
    aadhar_voter_card: { type: Object, default: null },
    token: { type: Boolean, default: false },
    status: { type: String, default: 'incomplete' },
    order: { type: String, ref: "Orders" },
    payment_status: { type: String, default: "unpaid" },
    created_at: { type: Date, default: Date.now },
    updated_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model("DscRegistration", dscRegistrationService);