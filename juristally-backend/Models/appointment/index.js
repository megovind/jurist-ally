const mongoose = require("mongoose");

const appointmentSchema = new mongoose.Schema({
    _id: mongoose.Schema.Types.ObjectId,
    appointment_no: { type: String, required: true },
    query: { type: String, required: true, ref: "UserQuery" },
    booked_by: { type: String, required: true, ref: "Users" },
    booked_to: { type: String, required: true, ref: "Users" },
    time_interval: { type: String, required: true, },
    date_of_appointment: { type: Date, default: Date.now },
    status: { type: String, default: "open" },
    created_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model("Appointments", appointmentSchema);
