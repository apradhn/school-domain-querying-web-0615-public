require_relative "../config/environment"

class Department
  attr_accessor :id, :name

  def insert
    sql = <<-SQL
      INSERT INTO departments(name)
      VALUES(?);
    SQL

    DB[:conn].execute(sql, self.name)

    sql = <<-SQL
      SELECT id 
      FROM departments
      ORDER BY id DESC
    SQL

    data = DB[:conn].execute(sql)
    self.id = data.flatten.first
  end

  def save
    persisted? ? update : insert
  end

  def persisted?
    !!self.id
  end

  def update
    sql = <<-SQL
      UPDATE departments
      SET name = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.id)
  end

  def courses
    Course.find_all_by_department_id(self.id)
  end

  def add_course(course)
    # is the course new or does it need to be updated?
    sql = <<-SQL
      SELECT * 
      FROM departments 
      INNER JOIN courses
      ON ? = courses.department_id
    SQL

    data = DB[:conn].execute(sql, self.id)
    if data.flatten.first.nil?
      sql = <<-SQL 
        INSERT INTO courses(name, department_id)
        VALUES (?, ?)
      SQL
    else
      sql = <<-SQL
        UPDATE courses(name, department_id)
        SET name = ?
        WHERE department_id = ?
      SQL
    end
    DB[:conn].execute(sql, course.name, self.id)
    self.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM departments 
      WHERE id = ?
    SQL
    data = DB[:conn].execute(sql, id).flatten
    if !(data.all?{|d| d.nil?})
      Department.new.tap do |c|
          c.id = data[0] 
          c.name = data[1]
      end
    end     
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM departments 
      WHERE name = ?
    SQL
    data = DB[:conn].execute(sql, name).flatten
    if !(data.all?{|d| d.nil?})
      Department.new.tap do |c|
          c.id = data[0] 
          c.name = data[1]
      end
    end 
  end

  def self.new_from_db(row)
    Department.new.tap do |d|
      d.id = row[0]
      d.name = row[1]
    end
  end
	 
   def self.create_table
     sql = <<-SQL
      CREATE TABLE IF NOT EXISTS departments
      (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT
        );
     SQL
     DB[:conn].execute(sql)
   end

   def self.drop_table
     sql = <<-SQL
     DROP TABLE IF EXISTS departments;
     SQL
     DB[:conn].execute(sql)
   end
end
