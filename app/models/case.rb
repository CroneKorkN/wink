class Case < ActiveRecord::Base
  belongs_to :case_type
  belongs_to :event_case, optional: true
  has_many :event_cases
  has_many :events,      through: :event_cases
  has_many :check_lists, through: :event_cases
  has_many :items
  has_many :locations, class_name: 'Item', foreign_key: 'case_id' # TODO

  validates :name, presence: true, uniqueness: true
  validates :acronym, presence: true, uniqueness: true
  validates :case_type, presence: true

  # Todo location
  #

  def locations # FIXME
    # an item that may contain other items, like a container of some sort
    # zum schalter machen
    Item.where("case_id = #{self.id} AND \
      deleted = false AND
      (item_type_id = #{ItemType.find_by(name: "Meshbag").id} or
      item_type_id = #{ItemType.find_by(name: "Fach").id})")
  end

  def sections
    # auch zum schalter is_section machen, ein item kann eine section sein
    # zum eigenen schalter machen, kann neben location existieren
    # NEIN: sections abschaffen, stattdessen locations verschachteln
    Item.where("case_id = #{self.id} AND \
      deleted = false AND
      item_type_id = #{ItemType.find_by(name: "Fach").id}")
  end

  def active_items
    Item.where("case_id = #{self.id} AND \
      deleted = false AND
      item_type_id NOT IN(
        #{ItemType.find_by(name: "Meshbag").id},
        #{ItemType.find_by(name: "Fach").id}
      )")
  end

  def check_list_exists?(event)
    if check_list(event).nil?
      false
    else
      true
    end
  end

  def check_list(event)
    ec = EventCase.find_by(event: event, case: self)

    if ec.nil? || ec.check_list.nil?
      nil
    else
      ec.check_list
    end
  end
end
