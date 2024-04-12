const passport = require("passport");
const express = require("express");

const router = express.Router();

const QueryController = require("../../Controllers/Query");


router.post(
    "/post-query",
    // passport.authenticate("jwt", { session: false }),
    QueryController.post_query
);

router.get(
    "/fetch-query-by-creater/:id",
    // passport.authenticate("jwt", { session: false }),
    QueryController.fetch_queries_by_creater
);

router.get(
    "/fetch-queries-by-type/:type/:id",
    // passport.authenticate("jwt", { session: false }),
    QueryController.fetch_query_by_type
);

module.exports = router;