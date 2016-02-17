module AuthHelper
  def profile_picture_of(user = nil, options = {})
    options[:class] ||= ''
    options[:class] += ' media-object img-circle profile-pic'
    options[:alt] ||= "#{user.try(:full_name) || '(Unknown)'}'s Avatar"
    options[:title] ||= user.try(:full_name) || 'Someone'

    image_tag user.try(:profile_picture_url) || 'avatar/masarie.jpg', options
  end

  def auth_server_error_banner
    return unless AuthModel.auth_server_down?

    content_tag :div, class: 'alert alert-danger' do
      content_tag :strong do
        (AuthModel.auth_server_went_down_at || Time.now).strftime(
          "WARNING: The authentication server is unreachable as of %I:%M%p. "\
          "Some site features might not function properly."
        )
      end
    end
  end
end
