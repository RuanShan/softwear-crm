class UseJsonInsteadOfYamlSerialization < ActiveRecord::Migration
  def up
    ActiveRecord::Base.connection.execute(
    %(UPDATE activities
      SET parameters='{}'
      WHERE parameters LIKE '--- !ruby/hash:ActiveSupport::HashWithIndifferentAccess%')
    )
    %(UPDATE activities
      SET parameters='{}'
      WHERE parameters LIKE '--- {%')
    )
  end
end
