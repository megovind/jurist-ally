const mongoose = require("mongoose");

const jobApplicationsSchema = new mongoose.Schema({
    _id: mongoose.Schema.Types.ObjectId,
    applicant: { type: String, default: null, ref: 'User' },
    name: { type: String, default: null },//full time part time or many
    email: { type: String, default: null },
    contact: { type: Object, default: null },
    resume: { type: String, default: null },
    cover_letter: { type: String, default: null },
    job: { type: String, default: null },
    created_at: { type: Date, default: Date.now },
    updated_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model("JobApplications", jobApplicationsSchema);