require "pry"

class Dog
  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def save
    sql = <<-SQL
    INSERT INTO dogs (name, breed) VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def update
    sql = <<-SQL
    UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  class << self
    def create_table
      self.drop_table
      sql = <<-SQL
      CREATE TABLE dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
      );
      SQL
      DB[:conn].execute(sql)
    end

    def drop_table
      DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    end

    def create(name:, breed:)
      new_dog = Dog.new(name: name, breed: breed)
      new_dog.save
      new_dog
    end

    def find_by_id(id)
      sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
      SQL
      dog = DB[:conn].execute(sql, id).flatten
      new_dog = Dog.new(id: dog[0], name: dog[1], breed: dog[2])
      new_dog
    end

    def find_or_create_by(name:, breed:)
      sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?
      SQL
      dog = DB[:conn].execute(sql, name, breed)
      dog_data = dog[0]
      if !dog.empty?
        new_dog = Dog.new_from_db(dog_data)
      else
        new_dog = Dog.create(name: name, breed: breed)
      end
    end

    def new_from_db(dog)
      id = dog[0]
      name = dog[1]
      breed = dog[2]
      Dog.new(id: id, name: name, breed: breed)
    end

    def find_by_name(name)
      sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
      SQL
      dog = DB[:conn].execute(sql, name).flatten
      new_dog = Dog.new(id: dog[0], name: dog[1], breed: dog[2])
      new_dog
    end
  end
end
