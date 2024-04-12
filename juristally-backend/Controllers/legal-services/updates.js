const services = require("../../services/legal-services.service");

exports.create_updates = async (type, typeId) => {
    let data;
    if (type === 'business_registration') {
        data = [
            {
                step: 0,
                service: typeId,
                step_text: "Verification",
                status: "pending",//Objection//unverified//verified//done
                handler_message: null,
                applicant_message: null,
                files: [],
                percentage: 0
            },
            {
                step: 1,
                service: typeId,
                step_text: "2 DSC Allotment(Number and Video Verification)",
                status: "pending",//Objection //unverified//verified//done
                handler_message: null,
                applicant_message: null,
                files: [],
                percentage: 7
            },
            {
                step: 2,
                service: typeId,
                step_text: "MOA/AOA/LAWs(NPO)",
                status: "pending",//Objection //unverified//verified//done
                handler_message: null,
                applicant_message: null,
                files: [],
                percentage: 14
            },
            {
                step: 3,
                service: typeId,
                step_text: "2 DIN Allotment(Director Identification Number)",
                status: "pending",//Objection //unverified//verified//done
                handler_message: null,
                applicant_message: null,
                files: [],
                percentage: 21
            },
            {
                step: 4,
                service: typeId,
                step_text: "Incorporation Certificate",
                status: "pending",//Objection //unverified//verified//done
                handler_message: null,
                applicant_message: null,
                files: [],
                percentage: 28
            },
            {
                step: 5,
                service: typeId,
                step_text: "PAN/TAN Certificate",
                status: "pending",//Objection //unverified//verified//done
                handler_message: null,
                applicant_message: null,
                files: [],
                percentage: 35
            },
            {
                step: 6,
                service: typeId,
                step_text: "EPFO/ESIC License",
                status: "pending",//Objection //unverified//verified//done
                handler_message: null,
                applicant_message: null,
                files: [],
                percentage: 42
            },
            {
                step: 7,
                service: typeId,
                step_text: "Open Current Bank Account",
                status: "pending",//Objection //unverified//verified//done
                handler_message: null,
                applicant_message: null,
                files: [],
                percentage: 49
            },
            {
                step: 8,
                service: typeId,
                step_text: "MSME Certificate",
                status: "pending",//Objection //unverified//verified//done
                handler_message: null,
                applicant_message: null,
                files: [],
                percentage: 56
            },
            {
                step: 9,
                service: typeId,
                step_text: "Get GSTN",
                status: "pending",//Objection //unverified//verified//done
                handler_message: null,
                applicant_message: null,
                files: [],
                percentage: 63
            },
            {
                step: 10,
                service: typeId,
                step_text: "Auditor Appointment(ADT-1)",
                status: "pending",//Objection //unverified//verified//done
                handler_message: null,
                applicant_message: null,
                files: [],
                percentage: 70
            },
            {
                step: 11,
                service: typeId,
                step_text: "Business Declaration(INC-20A)",
                status: "pending",//Objection //unverified//verified//done
                handler_message: null,
                applicant_message: null,
                files: [],
                percentage: 77
            },
            {
                step: 12,
                service: typeId,
                step_text: "First Year Compliance Free",
                status: "pending",//Objection //unverified//verified//done
                handler_message: null,
                applicant_message: null,
                files: [],
                percentage: 84
            },
            {
                step: 13,
                service: typeId,
                step_text: "Free Consultancy 3 Times",
                status: "pending",//Objection //unverified//verified//done
                handler_message: null,
                applicant_message: null,
                files: [],
                percentage: 91
            },
            {
                step: 14,
                service: typeId,
                step_text: "One Dedicated meeting with qualified Charted Accountant",
                status: "pending",//Objection //unverified//verified//done
                handler_message: null,
                applicant_message: null,
                files: [],
                percentage: 98
            },
            {
                step: 15,
                service: typeId,
                step_text: "Done",
                status: "pending",//Objection //unverified//verified//done
                handler_message: null,
                applicant_message: null,
                files: [],
                percentage: 100
            }
        ]
    } else if (type === "dsc_registration") {
        data = [
            {
                step: 0,
                service: typeId,
                step_text: "Verification",
                status: "pending",//Objection //unverified//verified//done
                handler_message: null,
                applicant_message: null,
                files: [],
                percentage: 0
            },
            {
                step: 1,
                service: typeId,
                step_text: "Delivery Initiated",
                status: "pending",//Objection //unverified//verified//done
                handler_message: null,
                applicant_message: null,
                files: [],
                percentage: 50
            },
            {
                step: 2,
                service: typeId,
                step_text: "Delivered",
                status: "pending",//Objection //unverified//verified//done
                handler_message: null,
                applicant_message: null,
                files: [],
                percentage: 100
            }
        ];
    } else if (type === 'tax_fillings') {
        data = [
            {
                step: 0,
                service: typeId,
                step_text: "Doc/GST Verification",
                status: "pending",//Objection//unverified//verified//done
                handler_message: null,
                applicant_message: null,
                files: [],
                percentage: 0
            },
            {
                step: 1,
                service: typeId,
                step_text: "Verify Computation(Raise query/Move forward)",
                status: "pending",//Objection//unverified//verified//done
                handler_message: null,
                applicant_message: null,
                files: [],
                percentage: 50
            },
            {
                step: 1,
                service: typeId,
                step_text: "Download IT Return/Challan",
                status: "pending",//Objection//unverified//verified//done
                handler_message: null,
                applicant_message: null,
                files: [],
                percentage: 100
            }
        ]
    }
    const updates = await services.INSERT_SERVICE_UPDATES(data); // LegalServiceUpdates.insertMany(data, { ordered: true });
    updates.forEach(async (el) => {
        if (type === 'business_registration') {
            response = await services.UPDATE_BUSINESS_REGISTRATION(typeId, { $push: { updates: el._id } });
        } else if (type === 'dsc_registration') {
            response = await services.UPDATE_DSC_REGISTRATION(typeId, { $push: { updates: el._id } });
        } else if (type === 'tax_fillings') {
            response = await services.UPDATE_ITR_GST_FILLINGS(typeId, { $push: { updates: el._id } });
        }
    });
    return true;
}