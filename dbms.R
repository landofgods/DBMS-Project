default_schemas <- list(
  "School Management" = list(
    tables = list(
      Students = list(
        columns = c("Student_ID", "Name", "Email_ID", "Contact_No", "Grade"),
        primary_key = "Student_ID",
        primary_key_type = "INT",
        primary_key_size = 10,
        foreign_keys = list()
      ),
      Teachers = list(
        columns = c("Teacher_ID", "Name", "Email_ID", "Contact_No", "Subject"),
        primary_key = "Teacher_ID",
        primary_key_type = "INT",
        primary_key_size = 10,
        foreign_keys = list()
      ),
      Classes = list(
        columns = c("Class_ID", "Class_Name", "Grade", "Teacher_ID"),
        primary_key = "Class_ID",
        primary_key_type = "INT",
        primary_key_size = 10,
        foreign_keys = list("Teacher_ID")
      ),
      Subjects = list(
        columns = c("Subject_ID", "Subject_Name", "Teacher_ID"),
        primary_key = "Subject_ID",
        primary_key_type = "INT",
        primary_key_size = 10,
        foreign_keys = list("Teacher_ID")
      ),
      Attendance = list(
        columns = c("Attendance_ID", "Student_ID", "Date", "Status"),
        primary_key = "Attendance_ID",
        primary_key_type = "INT",
        primary_key_size = 10,
        foreign_keys = list("Student_ID")
      ),
      Exams = list(
        columns = c("Exam_ID", "Student_ID", "Subject_ID", "Exam_Score"),
        primary_key = "Exam_ID",
        primary_key_type = "INT",
        primary_key_size = 10,
        foreign_keys = list("Student_ID", "Subject_ID")
      )
    ),
    relationships = list(
      c("Students", "Classes"),
      c("Teachers", "Classes"),
      c("Subjects", "Teachers"),
      c("Attendance", "Students"),
      c("Exams", "Students")
    )
  ),
  
  "Hospital Management" = list(
    tables = list(
      Patients = list(
        columns = c("Patient_ID", "Name", "Contact_Info", "DOB"),
        primary_key = "Patient_ID",
        primary_key_type = "INT",
        primary_key_size = 10,
        foreign_keys = list()
      ),
      Doctors = list(
        columns = c("Doctor_ID", "Name", "Specialization", "Contact_Info"),
        primary_key = "Doctor_ID",
        primary_key_type = "INT",
        primary_key_size = 10,
        foreign_keys = list()
      ),
      Appointments = list(
        columns = c("Appointment_ID", "Patient_ID", "Doctor_ID", "Date", "Time"),
        primary_key = "Appointment_ID",
        primary_key_type = "INT",
        primary_key_size = 10,
        foreign_keys = list("Patient_ID", "Doctor_ID")
      ),
      Treatments = list(
        columns = c("Treatment_ID", "Patient_ID", "Doctor_ID", "Diagnosis", "Medication"),
        primary_key = "Treatment_ID",
        primary_key_type = "INT",
        primary_key_size = 10,
        foreign_keys = list("Patient_ID", "Doctor_ID")
      ),
      Billing = list(
        columns = c("Bill_ID", "Patient_ID", "Amount", "Payment_Status"),
        primary_key = "Bill_ID",
        primary_key_type = "INT",
        primary_key_size = 10,
        foreign_keys = list("Patient_ID")
      )
    ),
    relationships = list(
      c("Patients", "Appointments"),
      c("Doctors", "Appointments"),
      c("Treatments", "Patients"),
      c("Billing", "Patients")
    )
  ),
  
  "University Management" = list(
    tables = list(
      Students = list(
        columns = c("Student_ID", "Name", "Email", "Contact_No", "Major"),
        primary_key = "Student_ID",
        primary_key_type = "INT",
        primary_key_size = 10,
        foreign_keys = list()
      ),
      Courses = list(
        columns = c("Course_ID", "Course_Name", "Semester", "Instructor"),
        primary_key = "Course_ID",
        primary_key_type = "INT",
        primary_key_size = 10,
        foreign_keys = list()
      ),
      Faculty = list(
        columns = c("Faculty_ID", "Name", "Department", "Contact_No"),
        primary_key = "Faculty_ID",
        primary_key_type = "INT",
        primary_key_size = 10,
        foreign_keys = list()
      ),
      Departments = list(
        columns = c("Department_ID", "Department_Name", "Head_ID"),
        primary_key = "Department_ID",
        primary_key_type = "INT",
        primary_key_size = 10,
        foreign_keys = list("Head_ID")
      ),
      Enrollment = list(
        columns = c("Enrollment_ID", "Student_ID", "Course_ID", "Grade"),
        primary_key = "Enrollment_ID",
        primary_key_type = "INT",
        primary_key_size = 10,
        foreign_keys = list("Student_ID", "Course_ID")
      ),
      Grades = list(
        columns = c("Grade_ID", "Student_ID", "Course_ID", "Grade"),
        primary_key = "Grade_ID",
        primary_key_type = "INT",
        primary_key_size = 10,
        foreign_keys = list("Student_ID", "Course_ID")
      )
    ),
    relationships = list(
      c("Students", "Enrollment"),
      c("Courses", "Enrollment"),
      c("Faculty", "Courses"),
      c("Departments", "Faculty"),
      c("Grades", "Enrollment")
    )
  ),
  
  "E-Commerce Platform" = list(
    tables = list(
      Products = list(
        columns = c("Product_ID", "Product_Name", "Price", "Stock", "Category"),
        primary_key = "Product_ID",
        primary_key_type = "INT",
        primary_key_size = 10,
        foreign_keys = list()
      ),
      Customers = list(
        columns = c("Customer_ID", "Name", "Email", "Contact_No", "Address"),
        primary_key = "Customer_ID",
        primary_key_type = "INT",
        primary_key_size = 10,
        foreign_keys = list()
      ),
      Orders = list(
        columns = c("Order_ID", "Customer_ID", "Order_Date", "Total_Amount"),
        primary_key = "Order_ID",
        primary_key_type = "INT",
        primary_key_size = 10,
        foreign_keys = list("Customer_ID")
      ),
      Payments = list(
        columns = c("Payment_ID", "Order_ID", "Payment_Method", "Payment_Status"),
        primary_key = "Payment_ID",
        primary_key_type = "INT",
        primary_key_size = 10,
        foreign_keys = list("Order_ID")
      ),
      Inventory = list(
        columns = c("Inventory_ID", "Product_ID", "Quantity", "Supplier"),
        primary_key = "Inventory_ID",
        primary_key_type = "INT",
        primary_key_size = 10,
        foreign_keys = list("Product_ID")
      ),
      Reviews = list(
        columns = c("Review_ID", "Product_ID", "Customer_ID", "Rating", "Comments"),
        primary_key = "Review_ID",
        primary_key_type = "INT",
        primary_key_size = 10,
        foreign_keys = list("Product_ID", "Customer_ID")
      )
    ),
    relationships = list(
      c("Products", "Orders"),
      c("Customers", "Orders"),
      c("Orders", "Payments"),
      c("Products", "Reviews")
    )
  )
)
