const mongoose = require("mongoose");

const jobsSchema = new mongoose.Schema({
    _id: mongoose.Schema.Types.ObjectId,
    recruiter: { type: String, default: null, ref: 'User' },
    company: { type: String, default: null },//full time part time or many
    profession: { type: String, default: null },
    job_location: { type: Object, default: null },
    salary_range: { type: String, default: null },
    job_type: { type: String, default: null },
    designation: { type: String, default: null },
    skills: { type: String, default: null },
    verified: { type: Boolean, default: false },
    description: { type: String, default: null },
    languages: { type: String, default: null },
    stream: { type: String, default: null },
    additional_skills: { type: String, default: null },
    apply_link: { type: String, default: null },
    applications: [{ type: String }],
    is_monthly: { type: Boolean, default: false },
    is_active: { type: String, default: 'active' },
    active_till: { type: Date, default: Date.now },
    created_at: { type: Date, default: Date.now },
    updated_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model("Jobs", jobsSchema);