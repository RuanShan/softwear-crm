
require 'spec_helper'
include ApplicationHelper

describe TimelineHelper do
  
  describe '#render_freshdesk_note' do
    let(:html) { "<blockquote class=\"freshdesk_quote\"></blockquote>" }
    
    it "inserts a button before every class='freshdesk_quote'" do 
      expect(helper.render_freshdesk_note(html)).to eq("<p><a href=\"#\" class=\"freshdesk-toggle-quoted btn btn-primary btn-sm\">Toggle Quoted Text</a></p><blockquote class=\"freshdesk_quote\"></blockquote>".html_safe)

    end
  end
end
