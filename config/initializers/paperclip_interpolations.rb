Paperclip.interpolates('assetable_type') do |attachment, style|
  attachment.instance.assetable_type
end

Paperclip.interpolates('assetable_id') do |attachment, style|
  attachment.instance.assetable_id
end

Paperclip.interpolates('id') do |attachment, style|
  attachment.instance.id
end