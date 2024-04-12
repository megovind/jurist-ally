const mongoose = require("mongoose");

const ordersSchema = new mongoose.Schema({
    _id: mongoose.Schema.Types.ObjectId,
    user: { type: String, default: null },
    order_id: { type: String, default: null },
    razorpay_order_id: { type: String, default: null },
    razorpay_payment_id: { type: String, default: null },
    razorpay_signature: { type: String, default: null },
    amount: { type: Number, default: 0 },
    amount_paid: { type: Number, default: 0 },
    amount_due: { type: Number, default: 0 },
    receipt_num: { type: String, default: null },
    curreny: { type: String, default: "INR" },
    status: { type: String, default: null },
    plan: { type: String, ref: 'Subscriptons' },
    service: { type: String, ref: "ServiceType" },
    other_item: { type: Object, default: null },
    referral_by: { type: String, default: null },
    created_at: { type: Date, default: Date.now },
    updated_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model("Orders", ordersSchema);