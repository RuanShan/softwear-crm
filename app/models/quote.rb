class Quote < ActiveRecord::Base
  include TrackingHelpers

  acts_as_paranoid

  tracked by_current_user

  belongs_to :salesperson, class_name: User
  belongs_to :store
  has_many :line_items, as: :line_itemable
  accepts_nested_attributes_for :line_items, allow_destroy: true

  # TODO: refactor to validator file
  validates :email, presence: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }
  validates :estimated_delivery_date, presence: true
  validates :first_name, presence: true
  # TODO: move to custom validator? reference style guide
  validate :has_line_items?
  validates :last_name, presence: true
  validates :salesperson_id, presence: true
  validates :store_id, presence: true
  validates :valid_until_date, presence: true

  def all_activities
    # TODO: use string literal? also general style
    PublicActivity::Activity.where( '
      (
        activities.recipient_type = ? AND activities.recipient_id = ?
      ) OR
      (
        activities.trackable_type = ? AND activities.trackable_id = ?
      )
    ', *([self.class.name, id] * 2) ).order('created_at DESC')
  end

  def create_freshdesk_ticket(current_user)
    freshdesk_info = fetch_data_to_h(current_user)
    # TODO: create softwearcrm freshdesk account
    client = Freshdesk.new('http://annarbortees.freshdesk.com/', 'david.s@annarbortees.com', 'testdesk')

    client.post_tickets(
        email: email,
        requester_id: freshdesk_info[:requester_id],
        requester_name: freshdesk_info[:requester_name],
        source: 2,
        group_id: freshdesk_info[:group_id],
        ticket_type: 'Lead',
        subject: 'Custom Apparel',
        custom_field: { department_7483: freshdesk_info[:department] }
    )
  end

  def fetch_data_to_h(current_user)
    # TODO: shouldn't need these comments
    # this function will, by default, set hash values to nil if anything is amiss
    freshdesk_info = {}

    # first add group_id and department
    freshdesk_info = fetch_group_id_and_dept(freshdesk_info)

    # now return that and requester id and name
    fetch_requester_id_and_name(freshdesk_info, current_user)
  end

  def fetch_group_id_and_dept(old_hash)
    new_hash = {}
    if store.name.downcase.include? 'arbor'
      # HACK: pretty sure this is the id freshdesk uses for Sales - Ann Arbor
      new_hash[:group_id] = 86316
      new_hash[:department] = 'Sales - Ann Arbor'
    elsif store.name.downcase.include? 'ypsi'
      new_hash[:group_id] = 86317
      new_hash[:department] = 'Sales - Ypsilanti'
    else
      new_hash[:group_id] = nil
      new_hash[:department] = nil
    end
    old_hash.merge(new_hash)
  end

  # FIXME: fix this
  def fetch_requester_id_and_name(old_hash, current_user)
    new_hash = {}
    if current_user.full_name.downcase == 'jack koch'
      new_hash[:requester_id] = Figaro.env['jacks_freshdesk_id']
      new_hash[:requester_name] = Figaro.env['jacks_freshdesk_name']

    elsif current_user.full_name.downcase == 'nathan kurple' || current_user.full_name.downcase == 'nate kurple'
      new_hash[:requester_id] = Figaro.env['nates_freshdesk_id']
      new_hash[:requester_name] = Figaro.env['nates_freshdesk_name']

    elsif current_user.full_name.downcase == 'george bekris'
      new_hash[:requester_id] = Figaro.env['georges_freshdesk_id']
      new_hash[:requester_name] = Figaro.env['georges_freshdesk_name']

    elsif current_user.full_name.downcase == 'barrie rupp'
      new_hash[:requester_id] = Figaro.env['barries_freshdesk_id']
      new_hash[:requester_name] = Figaro.env['barries_freshdesk_name']

    elsif current_user.full_name.downcase == 'michael marasco'
      new_hash[:requester_id] = Figaro.env['michaels_freshdesk_id']
      new_hash[:requester_name] = Figaro.env['michaels_freshdesk_name']

    else
      new_hash[:requester_id] = nil
      new_hash[:requester_name] = nil
    end
    old_hash.merge(new_hash)
  end

  def formatted_phone_number
    if phone_number
      # TODO: indent equals signs?
      area_code = phone_number[0, 3]
      middle_three = phone_number[3, 3]
      last_four = phone_number[6, 4]
      "(#{area_code}) #{middle_three}-#{last_four}"
    end
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def has_line_items?
    errors.add(:base, 'Quote must have at least one line item') if self.line_items.blank?
  end

  def line_items_subtotal
    line_items.map(&:total_price).reduce(0, :+)
  end

  def line_items_total_tax
    line_items.map{ |l| l.taxable? ? l.total_price * 0.06 : 0 }.reduce(0, :+)
  end

  def line_items_total_with_tax
    line_items.map { |l| l.taxable? ? l.total_price * 1.06 : l.total_price }.reduce(0, :+)
  end

  def standard_line_items
    LineItem.non_imprintable.where(line_itemable_id: id, line_itemable_type: 'Quote')
  end
end
