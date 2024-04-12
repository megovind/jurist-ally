const mongoose = require("mongoose");
const _ = require('lodash');

const Jobs = require("../../Models/Jobs");
const jobApplications = require("../../Models/Jobs/job-applications");

exports.post_job = async (req, res) => {
    try {
        const job = new Jobs({
            _id: mongoose.Types.ObjectId(),
            recruiter: req.body.recruiter,
            profession: req.body.profession,
            job_type: req.body.job_type,//full time part time or many
            company: req.body.company,
            job_location: req.body.job_location,
            salary_range: req.body.salary_range,
            designation: req.body.designation,
            skills: req.body.skills,
            languages: req.body.languages,
            stream: req.body.stream,
            additional_skills: req.body.additional_skills,
            active_till: req.body.active_till,
            description: req.body.description,
            is_monthly: req.body.is_monthly,
            apply_link: req.body.apply_link,
        })
        const response = await job.save();
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Something went wrong!" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

exports.edit_job = async (req, res) => {
    try {
        const id = req.params.id;
        const jobData = {
            profession: req.body.profession,
            job_type: req.body.job_type,//full time part time or many
            company: req.body.company,
            job_location: req.body.job_location,
            salary_range: req.body.salary_range,
            designation: req.body.designation,
            skills: req.body.skills,
            languages: req.body.languages,
            stream: req.body.stream,
            additional_skills: req.body.additional_skills,
            active_till: req.body.active_till,
            description: req.body.description,
            is_monthly: req.body.is_monthly,
            apply_link: req.body.apply_link,
        }
        const response = await Jobs.findByIdAndUpdate({ _id: id }, { $set: jobData });
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Something went wrong!" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

exports.fetch_job = async (req, res) => {
    try {
        const id = req.params.id;
        const response = await Jobs.findById({ _id: id }).exec();
        if (_.isEmpty(response)) {
            return res.send({ status: "NOT_FOUND", message: "Job not found!" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

exports.fetch_posted_jobs_by_recruiter = async (req, res) => {
    try {
        const id = req.params.id;
        const response = await Jobs.find({ recruiter: id });
        if (_.isEmpty(response)) {
            return res.send({ status: 'NOT_FOUND', message: "No Jobs has been posted yet!" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

exports.fetch_all_active_jobs = async (req, res) => {
    try {
        const response = await Jobs.find({ is_active: 'active' }).exec();
        if (_.isEmpty(response)) {
            return res.send({ status: "NOT_FOUND", message: "No active jobs found!" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

exports.mark_job_expired = async (req, res) => {
    try {
        const id = req.params.id;
        const response = await Jobs.findByIdAndUpdate({ _id: id }, { $set: { is_active: 'expired' } });
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Something went wrong!" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

exports.apply_for_job = async (req, res) => {
    try {
        const jobId = req.params.job_id;
        const applicantId = req.params.applicant_id;
        const application = new jobApplications({
            _id: mongoose.Types.ObjectId(),
            applicant: applicantId,
            job: jobId,
            name: req.body.name,
            email: req.body.email,
            contact: req.body.contact,
            resume: req.body.resume,
            cover_letter: req.body.cover_letter
        });
        const appRes = await application.save();
        if (_.isEmpty(appRes)) {
            return res.send({ status: "ERROR", message: 'Something went wrong' });
        }
        const response = await Jobs.findByIdAndUpdate({ _id: jobId }, { $push: { applications: applicantId } });
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Something went wrong!" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

exports.fetch_applied_jobs = async (req, res) => {
    try {
        const id = req.params.id;
        const response = await Jobs.find({ applications: id }).exec();
        if (_.isEmpty(response)) {
            return res.send({ status: "NOT_FOUND", message: 'Applied jobs not found' });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: 'ERROR', message: error.message });
    }
}