

class Participant {
  int? id;
  Person? person;

  Participant({
    this.id,
    this.person,
  });

  factory Participant.fromJson(Map<String, dynamic> json) => Participant(
        id: json["id"],
        person: json["person"] == null ? null : Person.fromJson(json["person"]),
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      "id": id,
    };
    
    if (person != null) {
      try {
        json["person"] = person!.toJson();
      } catch (e) {
        // If toJson fails, add a placeholder instead of null
        json["person"] = {};
      }
    }
    
    return json;
  }
}


class Person {
    int? id;
    String? firstName;
    String? lastName;
    String? phone;
    String? email;
    String? rollNumber;
    String? country;
    String? state;
    String? region;
    String? presentStatus;
    String? gender;
    DateTime? dob;
    String? presentAddressStreet;
    String? presentAddressState;
    String? presentAddressCity;
    String? presentAddressPin;
    String? presentAddressCountry;
    String? fatherName;
    String? maritalStatus;
    String? spouseName;

    Person({
        this.id,
        this.firstName,
        this.lastName,
        this.phone,
        this.email,
        this.rollNumber,
        this.country,
        this.state,
        this.region,
        this.presentStatus,
        this.gender,
        this.dob,
        this.presentAddressStreet,
        this.presentAddressState,
        this.presentAddressCity,
        this.presentAddressPin,
        this.presentAddressCountry,
        this.fatherName,
        this.maritalStatus,
        this.spouseName,
    });

    factory Person.fromJson(Map<String, dynamic> json) => Person(
        id: json["id"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        phone: json["phone"],
        email: json["email"],
        rollNumber: json["rollNumber"],
        country: json["country"],
        state: json["state"],
        region: json["region"],
        presentStatus: json["presentStatus"],
        gender: json["gender"],
        dob: json["dob"] == null ? null : DateTime.parse(json["dob"]),
        presentAddressStreet: json["presentAddressStreet"],
        presentAddressState: json["presentAddressState"],
        presentAddressCity: json["presentAddressCity"],
        presentAddressPin: json["presentAddressPin"],
        presentAddressCountry: json["presentAddressCountry"],
        fatherName: json["fatherName"],
        maritalStatus: json["maritalStatus"],
        spouseName: json["spouseName"],
    );

    Map<String, dynamic> toJson() {
      final Map<String, dynamic> json = {
        "id": id,
        "firstName": firstName,
        "lastName": lastName,
        "phone": phone,
        "email": email,
        "rollNumber": rollNumber,
        "country": country,
        "state": state,
        "region": region,
        "presentStatus": presentStatus,
        "gender": gender,
        "presentAddressStreet": presentAddressStreet,
        "presentAddressState": presentAddressState,
        "presentAddressCity": presentAddressCity,
        "presentAddressPin": presentAddressPin,
        "presentAddressCountry": presentAddressCountry,
        "fatherName": fatherName,
        "maritalStatus": maritalStatus,
        "spouseName": spouseName,
      };
      
      // Handle dob safely - this was causing the null check error
      if (dob != null) {
        json["dob"] = "${dob!.year.toString().padLeft(4, '0')}-${dob!.month.toString().padLeft(2, '0')}-${dob!.day.toString().padLeft(2, '0')}";
      }
      
      return json;
    }
}
