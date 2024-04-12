const moment = require("moment");
const { parse } = require("json2csv");
const refGenerator = require('voucher-code-generator')
const Users = require("../Models/Auth");
const LegalUpdates = require("../Models/LegalUpdates/index")
const Judgements = require("../Models/LegalUpdates/judgements");
const BareActs = require("../Models/LegalUpdates/bareact");
const { stringify } = require("querystring");

// export all the users in CSV
exports.export_users = async (req, res) => {
    try {
        const users = await Users.find().populate("subscription", "");
        const newUsers = users.map((usr) => {
            const newUsr = stringify(usr);
            usr.created_on = moment(usr.created_at).format("LL");
            return usr;
        });
        const fields = [
            {
                label: 'Name',
                value: 'full_name'
            },
            {
                label: "Gender",
                value: "gender"
            },
            {
                label: 'Phone Number',
                value: 'contact_number'
            },
            {
                label: 'Email Address',
                value: 'email'
            },
            {
                label: "Type",
                value: "type"
            },
            {
                label: "Membership type",
                value: "subscription.type"
            },
            {
                label: "Joined On",
                value: "created_on"
            }
        ];
        const opts = { fields };
        const csv = parse(newUsers, opts);
        res.header('Content-Type', 'text/csv');
        res.attachment(["users-", Date.now(), '.csv'].join(""));
        return res.send(csv);
    } catch (error) {
        return res.send({ status: "NOT GENERATED" });
    }
}

// export all the legal updates in CSV
exports.export_legal_updates = async (req, res) => {
    try {
        const lang = req.query.lang ? req.query.lang : "en";
        const updates = await LegalUpdates.find({ lang: lang });
        const fields = [
            {
                label: 'Name',
                value: 'act_rule'
            },
            {
                label: "File Link",
                value: "file"
            },
            {
                label: "Reference Link",
                value: "reference_link"
            }
        ];
        const opts = { fields };
        const csv = parse(updates, opts);
        res.header('Content-Type', 'text/csv');
        res.attachment(["legal-updates - ", lang, '.csv'].join(""));
        return res.send(csv);
    } catch (error) {
        return res.send({ status: "NOT GENERATED" });
    }
}

// export all the judgements in CSV
exports.export_judgements = async (req, res) => {
    try {
        const lang = req.query.lang ? req.query.lang : "en";
        const updates = await Judgements.find({ lang: lang });
        const fields = [
            {
                label: 'Name',
                value: 'court_name'
            },
            {
                label: "Title",
                value: "title",
            },
            {
                label: "File Link",
                value: "file"
            },
            {
                label: "DOJ",
                value: "date_of_judgement"
            },
            {
                label: "Reference Link",
                value: "reference_link"
            }
        ];
        const opts = { fields };
        const csv = parse(updates, opts);
        res.header('Content-Type', 'text/csv');
        res.attachment(["judgements - ", lang, '.csv'].join(""));
        return res.send(csv);
    } catch (error) {
        return res.send({ status: "NOT GENERATED" });
    }
}


// export all the judgements in CSV
exports.export_bare_acts = async (req, res) => {
    try {
        const lang = req.query.lang ? req.query.lang : "en";
        const updates = await BareActs.find({ lang: lang });
        const fields = [
            {
                label: 'Act',
                value: 'bare_act'
            },

            {
                label: "File Link",
                value: "file"
            }
        ];
        const opts = { fields };
        const csv = parse(updates, opts);
        res.header('Content-Type', 'text/csv');
        res.attachment(["bare-act - ", lang, '.csv'].join(""));
        return res.send(csv);
    } catch (error) {
        return res.send({ status: "NOT GENERATED" });
    }
}


exports.update_referral_code = async (req, res) => {
    try {
        const users = await Users.find().select("_id");
        users.map(async usr => {
            await Users.findByIdAndUpdate({ _id: usr._id }, { $set: { referral_code: getReferralCode() } });
        });
        return res.send({ status: "Updated" })
    } catch (error) {
        return res.send({ status: error.message });
    }
}

const getReferralCode = () => {
    return refGenerator.generate({ length: Math.floor(Math.random() * (12 - 6) + 6), count: 1, charset: refGenerator.charset('alphanumeric') })[0];
}