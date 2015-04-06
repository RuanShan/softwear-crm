class GetRidOfNameNumberPrint < ActiveRecord::Migration
  def up
    ActiveRecord::Base.connection.execute(
    %(
      DELETE FROM imprint_methods
      WHERE name = "Name/Number Print";
    ))
    unless ImprintMethod.where(name: 'Name/Number').exists?
    ActiveRecord::Base.connection.execute(
      %(
        INSERT INTO imprint_methods (name)
          VALUES "Name/Number"
      ))
    end
  end
end
