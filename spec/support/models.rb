class Employee < ActiveRecord::Base
  belongs_to :leader, class_name: 'Employee'
  has_many :employees, foreign_key: 'leader_id'
  has_one :task, inverse_of: false

  validates :name, presence: true
end

class Task < ActiveRecord::Base
  belongs_to :employee, inverse_of: false
end
