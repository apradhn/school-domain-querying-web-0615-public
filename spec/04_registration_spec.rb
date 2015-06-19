require_relative 'spec_helper'
require "pry"

describe Registration do

  before do
    Registration.create_table
  end

  after do
    Registration.drop_table
  end


  describe 'attributes' do 
    it 'has an id, course_id, student_id' do
      attributes = {
        :id => 1,
        :course_id => 35,
        :student_id => 84
      }

      registration = Registration.new
      registration.id = attributes[:id]
      registration.course_id = attributes[:course_id]
      registration.student_id = attributes[:student_id]

      expect(registration.id).to eq(attributes[:id])
      expect(registration.course_id).to eq(attributes[:course_id])
      expect(registration.student_id).to eq(attributes[:student_id])
    end
  end

  describe '.create_table' do
    it 'creates a Registrations table' do
      Registration.drop_table
      Registration.create_table
      table_check_sql = "SELECT tbl_name FROM sqlite_master WHERE type='table' AND tbl_name='registrations';"
      expect(DB[:conn].execute(table_check_sql)[0]).to eq(['registrations'])
    end
  end

  describe '.drop_table' do
    it "drops the Registrations table" do
      Registration.create_table
      Registration.drop_table

      table_check_sql = "SELECT tbl_name FROM sqlite_master WHERE type='table' AND tbl_name='registrations';"
      expect(DB[:conn].execute(table_check_sql)[0]).to be_nil
    end
  end
end