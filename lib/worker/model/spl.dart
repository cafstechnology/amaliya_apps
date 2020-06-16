class Spl{
  String title,
  description,
  scheduledStartDate,
  scheduledStartTime,
  scheduledEndDate,
  scheduledEndTime,
  customerName,
  supervisorName,
  fullName,
  status,
  lokasi,
  category,
  longitude,
  latitude,
  approvalStatus,
  id;
  Spl({
    this.title,
    this.description,
    this.scheduledStartDate,
    this.scheduledStartTime,
    this.scheduledEndDate,
    this.scheduledEndTime,
    this.customerName,
    this.supervisorName,
    this.fullName,
    this.status,
    this.lokasi,
    this.category,
    this.longitude,
    this.latitude,
    this.approvalStatus,
    this.id
  });

  Spl.fromJson(Map<String, dynamic> json){
    title       = json['title'];
    description       = json['description'];
    scheduledStartDate       = json['scheduledStartDate'];
    scheduledStartTime       = json['scheduledStartTime'];
    scheduledEndDate       = json['scheduledEndDate'];
    scheduledEndTime       = json['scheduledEndTime'];
    customerName       = json['customerName'];
    supervisorName       = json['supervisorName'];
    fullName       = json['fullName'];
    status       = json['status'];
    lokasi       = json['locationName'];
    category       = json['taskCategoryName'];
    longitude       = json['longitude'];
    latitude       = json['latitude'];
    approvalStatus       = json['approvalStatus'];
    id       = json['id'];
  }
}