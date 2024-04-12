class DropDownModel {
  String type;
  String value;

  DropDownModel(this.type, this.value);
}

List<DropDownModel> educationTypes = <DropDownModel>[
  DropDownModel('high_school', 'High School'),
  DropDownModel('intermediate', 'Intermediate'),
  DropDownModel('graduate', 'Graduate'),
  DropDownModel('post_graduate', "Post Graduate"),
  DropDownModel("diploma", "Diploma"),
  DropDownModel('ph_d', "PhD")
];

List<DropDownModel> experienceTypes = <DropDownModel>[
  DropDownModel('high_school', 'High School'),
  DropDownModel('intermediate', 'Intermediate'),
  DropDownModel('graduate', 'Graduate'),
  DropDownModel('post_graduate', "Post Graduate"),
  DropDownModel("diploma", "Diploma"),
  DropDownModel('ph_d', "PhD")
];

List<DropDownModel> typesList = [
  DropDownModel('lawyer', 'Lawyer'),
  DropDownModel('company_secretary', 'Company Secretary'),
  DropDownModel('chartered_accountant', "Chartered Accountant"),
  DropDownModel('student', 'Law Student'),
  DropDownModel('other', 'Other'),
];

List<DropDownModel> languagesList = [
  DropDownModel('en', 'English'),
  DropDownModel('hi', 'Hindi'),
];
