require "pry"
require_relative "../config/environment.rb"

class Course
  attr_accessor :id, :name, :department_id, :students
  @@all = []

  def initialize
    @@all << self 
    @students = []
  end

  def add_student(student)
    students << student
  end

  def department
    Department.find_by_id(department_id)
  end

  def department=(department)
    self.department_id = department.id
  end


  def insert
    sql = <<-SQL
      INSERT INTO courses(name, department_id) VALUES (?, ?);
    SQL

    DB[:conn].execute(sql, self.name, self.department_id)
    sql = <<-SQL
      SELECT id FROM courses ORDER BY id DESC LIMIT 1
    SQL
    id = DB[:conn].execute(sql).flatten.first
    self.id = id
  end

  def update
    sql = <<-SQL
      UPDATE courses
      SET name = ?, department_id = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.department_id, self.id) 
  end

  def save
    persisted? ? update : insert
  end

  def persisted?
    !!self.id
  end

  def self.new_from_db(array)
    obj = Course.new.tap do |c|
      c.id = array[0]
      c.name = array[1]
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM courses 
      WHERE name = ?
    SQL

    data = DB[:conn].execute(sql, name).flatten


    if !(data.all?{|d| d.nil?})
      Course.new.tap do |c|
          c.id = data[0] 
          c.name = data[1]
          c.department_id = data[2]
      end
    end

  end

  def Course.find_all_by_department_id(dept_id)
    sql = <<-SQL
      SELECT *
      FROM courses
      WHERE department_id = ?
    SQL

    data = DB[:conn].execute(sql, dept_id)
    data.collect do |d|
      Course.new.tap do |c|
        c.id = d[0]
        c.name = d[1]
        c.department_id = d[2]
      end
    end

  end

  def self.create_table
    sql =<<-SQL
      CREATE TABLE IF NOT EXISTS courses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        department_id INTEGER,
        FOREIGN KEY(department_id) REFERENCES department(id));
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS courses 
    SQL
    DB[:conn].execute(sql)
  end
end

