const passport = require("passport");
const express = require("express");
const router = express.Router();

const UpdateController = require("../../Controllers/LegalUpdates");
const LawsController = require("../../Controllers/LegalUpdates/laws")
const BareActController = require("../../Controllers/LegalUpdates/bare_act");
const LitigationsController = require("../../Controllers/Litigations");
const JudgementsController = require("../../Controllers/LegalUpdates/judgements");
// to deprecate
const JurisdictionLawController = require("../../Controllers/LegalUpdates/jurisdiction_law");

//Litigation MISs
router.post(
    "/litigation/create-mis-litigation",
    passport.authenticate("jwt", { session: false }),
    LitigationsController.create_litigation
);

router.get(
    "/litigation/fetch-mis-litigations",
    passport.authenticate("jwt", { session: false }),
    LitigationsController.fetch_litigations
);

router.get(
    "/litigation/fetch-mis-litigations-by-user/:user_id",
    passport.authenticate("jwt", { session: false }),
    LitigationsController.fetch_litigations_by_user
);

router.get(
    "/litigation/fetch-mis-litigation/:id",
    passport.authenticate("jwt", { session: false }),
    LitigationsController.fetch_litigation_by_id
);


router.post(
    "/litigation/update-court/:id",
    passport.authenticate("jwt", { session: false }),
    LitigationsController.update_court
);

router.post(
    "/litigation/update-clients/:id/:isOpponent",
    passport.authenticate("jwt", { session: false }),
    LitigationsController.update_client_opponent
)

router.post(
    "/litigation/update-advocates/:id/:isOpponent",
    passport.authenticate("jwt", { session: false }),
    LitigationsController.update_Advocate
)

router.post(
    "/litigation/update-hearing-date/:id/:isnext",
    passport.authenticate("jwt", { session: false }),
    LitigationsController.update_hearing_date
);

router.post(
    "/litigation/update-annexure/:id",
    passport.authenticate("jwt", { session: false }),
    LitigationsController.update_annexure
);

router.post(
    "/litigation/update-application_status/:id",
    passport.authenticate("jwt", { session: false }),
    LitigationsController.update_litigation_status
);

router.post(
    "/litigation/update-drafting/:id",
    passport.authenticate("jwt", { session: false }),
    LitigationsController.update_drafting
);

router.post(
    "/litigation/update-remarks/:id",
    passport.authenticate("jwt", { session: false }),
    LitigationsController.update_remarks
);

router.post(
    "/litigation/update-professional-fee/:id",
    passport.authenticate("jwt", { session: false }),
    LitigationsController.update_professional_fee
);

router.post(
    "/litigation/update-vakalatnama/:id",
    passport.authenticate("jwt", { session: false }),
    LitigationsController.update_vakalatnama
);

router.post(
    "/litigation/update-evidence/:id",
    passport.authenticate("jwt", { session: false }),
    LitigationsController.update_evidence
);

router.post(
    "/litigation/update-written-argument/:id",
    passport.authenticate("jwt", { session: false }),
    LitigationsController.update_written_argument
);

router.post(
    "/litigation/update-written-statement/:id",
    passport.authenticate("jwt", { session: false }),
    LitigationsController.update_written_statement
);

router.post(
    "/litigation/update-final-statement-argument/:id",
    passport.authenticate("jwt", { session: false }),
    LitigationsController.update_final_argument_judgement
);

router.post(
    "/litigation/update-available-document/:id",
    passport.authenticate("jwt", { session: false }),
    LitigationsController.update_available_document
);

router.post(
    "/litigation/add-contact-person/:id",
    passport.authenticate("jwt", { session: false }),
    LitigationsController.add_contact_person
);


router.post(
    "/litigation/search-mis-by-caseid/:case",
    passport.authenticate("jwt", { session: false }),
    LitigationsController.search_litigation_by_case
);

//to request an update on the case
router.post(
    "/litigation/request-update/:id/:user_id",
    passport.authenticate("jwt", { session: false }),
    LitigationsController.request_update
)

//bare act
router.post(
    "/add-bare-act",
    // passport.authenticate("jwt", { session: false }),
    BareActController.add_bare_act
);

router.get(
    "/fetch-bare-acts",
    // passport.authenticate("jwt", { session: false }),
    BareActController.fetch_bare_Acts
);

//law areas
router.post(
    "/add-law-area",
    // passport.authenticate("jwt", { session: false }),
    LawsController.add_law_area
);

router.get(
    "/fetch-law-areas",
    passport.authenticate("jwt", { session: false }),
    LawsController.fetch_law_area
);


//legal updates
router.post(
    "/add-legal-update",
    // passport.authenticate("jwt", { session: false }),
    UpdateController.add_legal_update
);

router.get(
    "/fetch-legal-updates",
    // passport.authenticate("jwt", { session: false })
    UpdateController.fetch_legalupdates
);

//jurisdiction law
router.post(
    "/add-judgement",
    // passport.authenticate("jwt", {session:false}),
    JudgementsController.add_judgement
);

router.post(
    "/fetch-judgements",
    passport.authenticate("jwt", { session: false }),
    JudgementsController.fetch_judgements
);

//to be deprected
router.get(
    "/fetch-jurisdiction-law",
    passport.authenticate("jwt", { session: false }),
    JurisdictionLawController.fetch_jurisdction_law
);

//utilities
router.post(
    "/update-caseids",
    LitigationsController.update_case_id
)


module.exports = router;