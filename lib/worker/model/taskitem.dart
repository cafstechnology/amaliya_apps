class TaskItem{
  String title,
  start,
  end,
  id,
  name,
  custname,
  date,
  full_name,
  workstatus,
  code,
  longitude,
  latitude,
  desc,
  remarksDone,
  remarksSpv,
  location;
  TaskItem({
    this.title,
    this.start,
    this.end,
    this.name,
    this.id,
    this.custname,
    this.date,
    this.full_name,
    this.workstatus,
    this.code,
    this.desc,
    this.longitude,
    this.latitude,
    this.remarksDone,
    this.remarksSpv,
    this.location
  });

  TaskItem.fromJson(Map<String, dynamic> json){
    title       = json['title'];
    start       = json['start'];
    end       = json['end'];
    name       = json['name'];
    id       = json['id'];
    code       = json['code'];
    custname       = json['custname'];
    date       = json['date'];
    full_name       = json['full_name'];
    workstatus       = json['workStatus'];
  }
}