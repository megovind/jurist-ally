const mongoose = require("mongoose");
const AWS = require("aws-sdk");
const _ = require("lodash");

const JurisdictionLaw = require("../../Models/LegalUpdates/jurisdiction_law");

exports.add_jurisdiction_law = async (req, res) => {
    try {
        if (_.isEmpty(req.file) || _.isEmpty(req.body.jurisdiction_law)) {
            return res.send({ status: 'ERROR', message: 'Please provide all the correct details!' });
        }
        const s3Bucket = new AWS.S3({
            accessKeyId: process.env.AMAZONACCESSKEYID,
            secretAccessKey: process.env.AMAZONSECRETACCESSKEY,
            Bucket: process.env.AMAZONS3BUCKETNAME
        });

        const file = req.file;
        if (!_.isEmpty(file)) {
            const params = {
                Bucket: process.env.AMAZONS3BUCKETNAME,
                Key: new Date().toISOString() + "-" + file.originalname,
                Body: file.buffer,
                ContentType: file.mimetype,
                ACL: "public-read"
            }
            s3Bucket.upload(params, async (error, data) => {
                if (error) {
                    return res.send({ status: 'ERROR', message: error.message });
                }
                const jurisdiction = new JurisdictionLaw({
                    _id: mongoose.Types.ObjectId(),
                    court: req.body.court_name,
                    jurisdiction_law: req.body.title,
                    file: data.Location,
                    year: req.body.year,
                    passed_on: req.body.date_of_judgement
                });
                const response = await jurisdiction.save();
                if (_.isEmpty(response)) {
                    return res.send({ status: 'ERROR', message: 'Something went wrong!' })
                }
                return res.send({ status: 'SUCCESS', response });
            })
        }
    } catch (error) {
        return res.send({ status: 'ERROR', message: error.message });
    }
}

exports.fetch_jurisdction_law = async (req, res) => {
    try {
        const response = await JurisdictionLaw.find().sort({ passed_on: -1 }).exec();
        if (_.isEmpty(response)) {
            return res.send({ status: "NOT_FOUND", message: 'Jurisdiction & law not found' });
        }
        return res.send({ status: 'SUCCESS', response });
    } catch (error) {
        return res.send({ status: 'ERROR', message: error.message });
    }
}