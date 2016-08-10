class Carwash < ActiveRecord::Base
  validates :title, :slug, :address, :start_time, :end_time, :presence => true

  mount_uploader :logo, LogoUploader

  belongs_to :area
  belongs_to :city
  belongs_to :owner, :class_name => 'User'
  has_many :users
  has_many :clients
  has_many :boxes
  has_many :price_groups
  has_many :services
  has_many :photos
  has_many :tickets

  default_scope where(locked: false, enabled: true)

  def boxes_with_tickets_for_date(date = nil)
    bxs = self.boxes.all
    return {} if bxs.empty?
    tickets = Ticket.for_date(date).where(:box_id => bxs.collect(&:id)).all
    rs = {}
    bxs.each {|b| rs[b] = tickets.find_all {|t| t.box_id == b.id}}

    rs
  end

  def visible_boxes_with_tickets_for_date(date = nil)
    bxs = self.boxes.where(visible_in_search_results: true).all
    return {} if bxs.empty?
    tickets = Ticket.for_date(date).where(:box_id => bxs.collect(&:id)).all
    rs = {}
    bxs.each {|b| rs[b] = tickets.find_all {|t| t.box_id == b.id}}

    rs
  end

  def timeline(date, time, opts = {})
    CarwashTimeline.new(self, date, time, opts)
  end

  def new_tickets
    tickets.where(:status => Ticket::NEW).order('date desc, start_time asc')
  end

  def open_tickets
    tickets.where(:status => Ticket::OPEN).order('date desc, start_time asc')
  end

  def pretty_title
    "&laquo;#{title}&raquo; #{address}".html_safe
  end

  def url_string
    return '' if url.blank?
    url.gsub('http://', '').gsub('www.', '')
  end

  def start_time_string
    self.start_time.strftime('%H:%M')
  end

  def start_time_string=(start_time_string)
    self.start_time = Time.zone.parse(start_time_string)
  end

  def end_time_string
    self.end_time.strftime('%H:%M')
  end

  def end_time_string=(end_time_string)
    self.end_time = Time.zone.parse(end_time_string)
  end

  def all_day_long?
    true if self.start_time.strftime('%H:%M') == "00:00" && self.end_time.in_minutes > 1400
  end

  def open_at_time?(s_time)
    res = s_time.in_minutes > self.end_time.in_minutes || s_time.in_minutes < self.start_time.in_minutes ? false : true
  end
end


----------------------------------------------------------------------------------------


class Carwash < ActiveRecord::Base
  include CarwashAssociations

  validates :title, :slug, :address, :start_time, :end_time, :presence => true

  mount_uploader :logo, LogoUploader

  # default_scope where(locked: false, enabled: true)

  def boxes_with_tickets_for_date(date = nil)
    BoxesWithTicketsBuilder.new(boxes, date)
  end

  def visible_boxes_with_tickets_for_date(date = nil)
    BoxesWithTicketsBuilder.new(boxes.where(visible_in_search_results: true), date)
  end

  def timeline(date, time, opts = {})
    CarwashTimeline.new(self, date, time, opts)
  end

  def new_tickets
    tickets.new
  end

  def open_tickets
    tickets.open
  end

  def all_day_long?
    start_time.strftime('%H:%M') == "00:00" && end_time.in_minutes > 1400
  end

  def open_at_time?(s_time)
    (start_time.in_minutes..end_time.in_minutes).include? s_time.in_minutes
  end
end

module CarwashAssociations
  extend ActiveSupport::Concern

  included do
    belongs_to :area
    belongs_to :city
    belongs_to :owner, :class_name => 'User'
    has_many :users
    has_many :clients
    has_many :boxes
    has_many :price_groups
    has_many :services
    has_many :photos
    has_many :tickets
  end
end

class Ticket < ActiveRecord::Base
  scope :ordered, -> { order('date desc, start_time asc') }
  scope :new, -> { where(:status => Ticket::NEW).ordered }
  scope :open, -> { where(:status => Ticket::OPEN).ordered }
end

class CarwashDecorator < Draper::Decorator
  def pretty_title
    "&laquo;#{title}&raquo; #{address}".html_safe
  end

  def url_string
    return '' if url.blank?
    url.gsub('http://', '').gsub('www.', '')
  end

  def start_time_string
    self.start_time.strftime('%H:%M')
  end

  def start_time_string=(start_time_string)
    self.start_time = Time.zone.parse(start_time_string)
  end

  def end_time_string
    self.end_time.strftime('%H:%M')
  end

  def end_time_string=(end_time_string)
    self.end_time = Time.zone.parse(end_time_string)
  end
end
