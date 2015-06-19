require_relative "../config/environment.rb"

class Registration
	attr_accessor :id, :course_id, :student_id

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS registrations(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        course_id INTEGER,
        student_id INTEGER,
        FOREIGN KEY(course_id) REFERENCES courses(id),
        FOREIGN KEY (student_id) REFERENCES students(id))
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS registrations
    SQL
    DB[:conn].execute(sql)
  end
end