factory(Employee) do
  blueprint :leader, name: 'Leader'
  blueprint :employee, name: 'Employee', leader: leader
end

factory(Task) do
  blueprint :task, title: 'do stuff', employee: leader
  blueprint :do_laundry, title: 'do laundry'
end

blueprint :employee_form_class do
  Class.new(JsonForm::Form)
end

blueprint :task_form_class do
  Class.new(JsonForm::Form)
end

depends_on(:employee_form_class, :leader).blueprint :leader_form do
  employee_form_class.new(leader)
end
