const mongoose = require('mongoose');

const passwordToken = mongoose.Schema({
    _id: mongoose.Schema.Types.ObjectId,
    token: { type: String, default: null },
    mailphone: { type: String, default: null },
    expire_at: { type: Date, default: Date.now },
    created_at: { type: Date, default: Date.now },
    updated_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model('PasswordToken', passwordToken);