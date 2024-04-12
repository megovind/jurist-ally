const mongoose = require("mongoose");

const litigationsSchema = new mongoose.Schema({
    _id: mongoose.Schema.Types.ObjectId,
    user_id: { type: String, default: null, ref: "Users" },
    case_id: { type: String, default: null },
    case_number: { type: String, default: null },
    case_type: { type: String, default: null },
    file_no: { type: String, default: null },
    title: { type: String, default: null },
    brief_case: { type: String, default: null },
    claim: { type: String, default: null },
    place: { type: Object, default: null },
    client: { type: Object, default: null },
    client_oppo: { type: Object, default: null },
    client_names: { type: Array },
    court_details: { type: Object, default: null },
    complaint_no: { type: String, default: null },
    advocate: { type: Object, default: null },
    oppo_advocate: { type: Object, default: null },
    law_firm_name: { type: String, default: null },
    contact_person: { type: Object, default: null },
    date_of_hearings: [{ type: Object, default: null }],
    next_hearing_date: { type: Object, default: null },
    annexure: { type: Object, default: null },
    application_status: { type: Object, default: null },
    drafting: { type: Object, default: null },
    remarks: [{ type: Object, default: null }],
    professional_fee: {
        total_amount: { type: Number, default: 0 },
        advance: [{ type: Object }]
    },
    vakalatnama: { type: Object, default: null },
    evidence: { type: Object, default: null },
    written_statement: { type: Object, default: null },
    written_argument: { type: Object, default: null },
    available_document: { type: Object, default: null },
    final_argument: { type: Object, default: null },
    final_judgement: { type: Object, default: null },
    start_date: { type: Date, default: Date.now },
    end_date: { type: Date, default: Date.now },
    created_at: { type: Date, default: Date.now },
    updated_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model("Litigations", litigationsSchema);