require_relative "../config/environment.rb"

class Student
	attr_accessor :name, :grade
	attr_reader :id

	def initialize(name, grade, id = nil)
		@name = name
		@grade = grade
		@id = id
	end

	def self.create_table
		sql = <<-SQL
		CREATE TABLE IF NOT EXISTS students(
			id INTEGER PRIMARY KEY,
			name text,
			grade INTEGER);
		SQL
		
		DB[:conn].execute(sql)

	end

	def self.drop_table
		sql = <<-SQL
		DROP TABLE students;
		SQL

		DB[:conn].execute(sql)
	end

	def save
		if @id == nil
		    sql = <<-SQL
		      INSERT INTO students (name, grade) 
		      VALUES (?, ?);
		    SQL

		    DB[:conn].execute(sql, self.name, self.grade)

		    sql = <<-SQL
		    	SELECT id
		    	FROM students
		    	WHERE name = ?
		    SQL

		    @id = DB[:conn].execute(sql, self.name)[0][0]

		    self
		else
			self.update
		end
	end

	def self.create(name,grade)
		student = self.new(name, grade)
		student.save
	end

	def self.new_from_db(row)
	    new_student = self.new(row[1],row[2],row[0])
	    new_student
	end

	def self.find_by_name(name)
	    sql = <<-SQL
	      SELECT *
	      FROM students
	      WHERE name = ?
	    SQL

	    found_student = self.new_from_db(DB[:conn].execute(sql, name).first)
	    found_student
	end

	def update
		sql = <<-SQL
		UPDATE students
		SET name = ?, grade = ?
		WHERE id = ?
		SQL

		DB[:conn].execute(sql, self.name, self.grade, self.id)
		self
	end


end
