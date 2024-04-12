const passport = require("passport");
const express = require("express");
const router = express.Router();

const LegalServicesController = require("../../controllers/legal-services/business-registraton");
const CategoriesController = require("../../controllers/legal-services/categories");
const ItrGstController = require("../../controllers/legal-services/file-itr-gst");
const DSCController = require("../../controllers/legal-services/dsc-regitration")

//Legal services
router.post(
    "/apply-for-business-registration",
    passport.authenticate("jwt", { session: false }),
    LegalServicesController.create_business_registeration
);

router.post(
    "/update-business-registration/:id",
    passport.authenticate("jwt", { session: false }),
    LegalServicesController.update_business_registration
);


router.post(
    "/apply-for-dsc",
    passport.authenticate("jwt", { session: false }),
    DSCController.dsc_registration
);

router.post(
    "/update-dsc-registration/:id",
    passport.authenticate("jwt", { session: false }),
    DSCController.update_dsc_registration
);

router.post(
    "/file-itr-gst",
    passport.authenticate("jwt", { session: false }),
    ItrGstController.file_itr_gst
);

router.post(
    "/update-file-itr-gst/:id",
    passport.authenticate("jwt", { session: false }),
    ItrGstController.update_itr_gst
);

router.post(
    "/register-director/:id",
    passport.authenticate("jwt", { session: false }),
    LegalServicesController.register_director
);
// Update director details which is basically all details for dsc
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
    passport.authenticate("jwt", { session: false }),
    LegalServicesController.update_legal_service_updates
);

// router.post(
//     "/update-address-proof/:id",
//     passport.authenticate("jwt", { session: false }),
//     LegalServicesController.update_address_proof
// );

router.post(
    "/fetch-incomplete",
    passport.authenticate("jwt", { session: false }),
    LegalServicesController.fetch_incomplete_service
);

router.post(
    "/fetch-service/:id",
    passport.authenticate("jwt", { session: false }),
    LegalServicesController.fetch_service
);

router.post(
    "/fetch-services",
    passport.authenticate("jwt", { session: false }),
    LegalServicesController.fetch_Services_by_user
);

router.post(
    "/fetch-services-by-handler",
    passport.authenticate("jwt", { session: false }),
    LegalServicesController.fetch_Services_by_handler
);


//Categories
router.post(
    "/add-category",
    passport.authenticate("jwt", { session: false }),
    CategoriesController.add_categories
);

router.post(
    "/update-category/:id",
    passport.authenticate("jwt", { session: false }),
    CategoriesController.update_category
)

router.post(
    "/fetch-services-categories",
    passport.authenticate("jwt", { session: false }),
    CategoriesController.fetch_service_category
)

module.exports = router;