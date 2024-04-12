const passport = require("passport");
const express = require("express");
const router = express.Router();

const Utilities = require("../../Utilities/amaon-s3");
const mailUtil = require("../../Utilities/send_mail");
const CSVController = require("../../Utilities/create_csv");

//to upload file on s3 bucket
router.post(
    "/upload-files",
    // passport.authenticate("jwt", { session: false }),
    Utilities.upload_file_to_s3
);


router.post(
    "/send-email",
    //passport.authenticate("jwt", {session: fase}),
    mailUtil.send_email
);


router.get(
    "/generate-users-list",
    CSVController.export_users
);

router.get(
    "/legal-updates-list",
    CSVController.export_legal_updates
);

router.get(
    "/bare-act-list",
    CSVController.export_bare_acts
);

router.get(
    "/judgement-list",
    CSVController.export_judgements
);

router.post('/update-referral-codes', CSVController.update_referral_code);


module.exports = router;