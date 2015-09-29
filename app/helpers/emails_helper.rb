module EmailsHelper
  def backtrace_is_from_app?(line)
    !(line.include?('/gems/') || /^kernel\// =~ line || line.include?('/vendor_ruby/'))
  end

  extend self
end
