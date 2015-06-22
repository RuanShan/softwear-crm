Kernel.module_eval do
  def ci?
    ENV['CI'] == 'true'
  end
end
