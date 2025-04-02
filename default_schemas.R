# Default Database Schemas Module
schemas <- list(
  "School Management" = list(
    description = "A database schema designed to manage school operations, including student and teacher records, class schedules, attendance tracking, and exam results.",
    tables = list(
      Students = c("Student_ID", "Name", "Email_ID", "Contact_No", "Grade"),
      Teachers = c("Teacher_ID", "Name", "Email_ID", "Contact_No", "Subject"),
      Classes = c("Class_ID", "Class_Name", "Grade", "Teacher_ID"),
      Subjects = c("Subject_ID", "Subject_Name", "Teacher_ID"),
      Attendance = c("Attendance_ID", "Student_ID", "Date", "Status"),
      Exams = c("Exam_ID", "Student_ID", "Subject_ID", "Exam_Score")
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
    description = "A schema to manage hospital operations, including patient records, doctor schedules, appointments, treatments, and billing.",
    tables = list(
      Patients = c("Patient_ID", "Name", "Contact_Info", "DOB"),
      Doctors = c("Doctor_ID", "Name", "Specialization", "Contact_Info"),
      Appointments = c("Appointment_ID", "Patient_ID", "Doctor_ID", "Date", "Time"),
      Treatments = c("Treatment_ID", "Patient_ID", "Doctor_ID", "Diagnosis", "Medication"),
      Billing = c("Bill_ID", "Patient_ID", "Amount", "Payment_Status")
    ),
    relationships = list(
      c("Patients", "Appointments"),
      c("Doctors", "Appointments"),
      c("Treatments", "Patients"),
      c("Billing", "Patients")
    )
  ),
  "University Management" = list(
    description = "A schema designed for managing university operations, including student enrollments, courses, faculty, and department details.",
    tables = list(
      Students = c("Student_ID", "Name", "Email", "Contact_No", "Major"),
      Courses = c("Course_ID", "Course_Name", "Semester", "Instructor"),
      Faculty = c("Faculty_ID", "Name", "Department", "Contact_No"),
      Departments = c("Department_ID", "Department_Name", "Head_ID"),
      Enrollment = c("Enrollment_ID", "Student_ID", "Course_ID", "Grade"),
      Grades = c("Grade_ID", "Student_ID", "Course_ID", "Grade")
    ),
    relationships = list(
      c("Students", "Enrollment"),
      c("Courses", "Enrollment"),
      c("Faculty", "Courses"),
      c("Departments", "Faculty"),
      c("Grades", "Enrollment")
    )
  )
  # Add remaining designs following the same structure
)
