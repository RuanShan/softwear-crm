Injectable.TestInjection do
  scope :test_scope, -> { unscoped.where name: 'testy' }
  def test_func
    puts 'OR WILL IT. ' + name
  end
end
