const passport = require("passport");
const express = require('express');
const router = express.Router();

const JobController = require("../../Controllers/Jobs");


router.post(
    "/post-job",
    passport.authenticate("jwt", { session: false }),
    JobController.post_job
);

router.patch(
    "/update-posted-job/:id",
    passport.authenticate("jwt", { session: false }),
    JobController.edit_job
);

router.patch(
    "/mark-expired/:id",
    passport.authenticate("jwt", { session: false }),
    JobController.mark_job_expired
);

router.patch(
    "/send-job-application/:job_id/:applicant_id",
    passport.authenticate("jwt", { session: false }),
    JobController.apply_for_job
);

router.get(
    "/fetch-applied-jobs/:id",
    passport.authenticate("jwt", { session: false }),
    JobController.fetch_applied_jobs
)

router.get(
    "/fetch-job/:id",
    passport.authenticate("jwt", { session: false }),
    JobController.fetch_job
);

router.get(
    "/fetch-active-jobs",
    passport.authenticate("jwt", { session: false }),
    JobController.fetch_all_active_jobs
);

module.exports = router;