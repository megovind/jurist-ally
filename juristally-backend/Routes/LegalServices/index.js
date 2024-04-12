const passport = require("passport");
const express = require("express");
const router = express.Router();

const LegalServicesController = require("../../Controllers/LegalServices/BusinessRegistraton/index");
const CategoriesController = require("../../Controllers/LegalServices/categories");
const DscController = require("../../Controllers/LegalServices/DSCRegistration");
const ItrGstController = require("../../Controllers/LegalServices/FileItrGst");

//Legal services
router.post(
    "/apply-for-service",
    // passport.authenticate("jwt", { session: false }),
    LegalServicesController.register_service
);

router.post(
    "/apply-for-dsc",
    passport.authenticate("jwt", { session: false }),
    DscController.dsc_registration
);

router.post(
    "/file-itr-gst",
    passport.authenticate("jwt", { session: false }),
    ItrGstController.file_itr_gst
);

router.post(
    "/update-itrgst-details/:sId/:dId",
    passport.authenticate("jwt", { session: false }),
    ItrGstController.update_itr_gst_details
);

router.post(
    "/update-file-itr-gst/:id",
    passport.authenticate("jwt", { session: false }),
    ItrGstController.update_itr_gst
);

router.post(
    "/update-service/:id",
    passport.authenticate("jwt", { session: false }),
    LegalServicesController.update_service
);

router.post(
    "/register-director/:id",
    passport.authenticate("jwt", { session: false }),
    LegalServicesController.register_director
);

router.post(
    "/update-director-details/:d_id/:s_id",
    passport.authenticate("jwt", { session: false }),
    LegalServicesController.update_director_details
);

router.post(
    "/remove-director/:d_id/:s_id",
    passport.authenticate("jwt", { session: false }),
    LegalServicesController.delete_director
)

router.post(
    "/update-service-updates-status/:id",
    // passport.authenticate("jwt", { session: false }),
    LegalServicesController.update_legal_service_updates
);

router.post(
    "/update-address-proof/:id",
    passport.authenticate("jwt", { session: false }),
    LegalServicesController.update_address_proof
);

router.post(
    "/fetch-incomplete/:type_id/:user_id",
    passport.authenticate("jwt", { session: false }),
    LegalServicesController.fetch_incomplete_service
);

router.post(
    "/fetch-service/:id",
    passport.authenticate("jwt", { session: false }),
    LegalServicesController.fetch_service
);

router.post(
    "/fetch-services/:user",
    passport.authenticate("jwt", { session: false }),
    LegalServicesController.fetch_Services_by_user
);

router.post(
    "/fetch-services-by-handler/:handler_id",
    passport.authenticate("jwt", { session: false }),
    LegalServicesController.fetch_Services_by_handler
);

// router.post(
//     "/update-application-status/:id",
//     passport.authenticate("jwt", { session: false }),
//     LegalServicesController.update_status
// );


//Categories
router.post(
    "/add-category",
    // passport.authenticate("jwt", { session: false }),
    CategoriesController.add_categories
);

router.post(
    "/update-category/:id",
    // passport.authenticate("jwt", { session: false }),
    CategoriesController.update_category
)

router.post(
    "/fetch-services-categories/:user",
    passport.authenticate("jwt", { session: false }),
    CategoriesController.fetch_service_category
)

module.exports = router;