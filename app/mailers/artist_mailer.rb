class ArtistMailer < ActionMailer::Base
  default from: 'noreply@softwearcrm.com'

  def artist_notification(artwork_request, action_name)
    @salesperson = artwork_request.salesperson
    @artist = artwork_request.artist
    @artwork_request = artwork_request
    @action_name = action_name

    mail to: @artist.email, subject: 'Notification regarding your Artwork Requests'
  end
end
