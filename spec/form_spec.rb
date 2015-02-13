require 'spec_helper'

describe JsonForm::Form do
  describe ".attributes" do
    build :employee_form_class

    it "adds assigned attributes" do
      employee_form_class.class_eval do
        attributes :name
        attributes :age, :height
      end
      expect(employee_form_class.assigned_attributes).to eq([:name, :age, :height])
    end
  end

  describe ".embeds_many" do
    build :employee_form_class

    it "adds association" do
      task_form_class = build(:task_form_class)
      employee_form_class.class_eval do
        embeds_many :employees, self
        embeds_many :tasks, task_form_class
      end

      expect(employee_form_class.associations.keys).to eq([:employees, :tasks])
      expect(employee_form_class.associations[:tasks]).to eq([JsonForm::EmbedsManyAssociation, task_form_class])
      expect(employee_form_class.associations[:employees]).to eq([JsonForm::EmbedsManyAssociation, employee_form_class])
    end

    it "adds association with inline form" do
      employee_form_class.class_eval do
        embeds_many :employees do
          attributes :name
        end
      end

      form_class = employee_form_class.associations[:employees][1]
      expect(form_class.ancestors[1]).to eq(JsonForm::Form)
      expect(form_class.attributes).to eq([:name])
    end
  end

  describe ".embeds_one" do
    build :employee_form_class, :task_form_class

    it "adds association" do
      task_form_class = self.task_form_class
      employee_form_class.class_eval do
        embeds_one :employee, self
        embeds_one :task, task_form_class
      end

      expect(employee_form_class.associations.size).to eq(2)
      expect(employee_form_class.associations.keys).to eq([:employee, :task])
      expect(employee_form_class.associations[:task]).to eq([JsonForm::EmbedsOneAssociation, task_form_class])
    end
  end

  describe "#attributes=" do
    build :leader_form

    it "assigns attributes" do
      employee_form_class.class_eval do
        attributes :name, :monthly_pay
      end
      leader_form.attributes = {name: 'new name', monthly_pay: 10_000}
      expect(leader.name).to eq('new name')
      expect(leader.monthly_pay).to eq(10_000)
    end

    it "doesn't assign attributes that are not accepted" do
      leader_form.attributes = {name: 'new name'}
      expect(leader.name).to eq('Leader')
    end

    it "doesn't assign attributes that are not passed" do
      employee_form_class.class_eval do
        attributes :name
      end
      leader_form.attributes = {}
      expect(leader.name).to eq('Leader')
    end

    it "converts camel case to underscore notation" do
      employee_form_class.class_eval do
        attributes :monthly_pay
      end
      leader_form.attributes = {monthlyPay: 10_000}
      expect(leader.monthly_pay).to eq(10_000)
    end

    context "embeds many association with another form" do
      before do
        employee_form_class.class_eval do
          attributes :name
          embeds_many :employees, self

          def attributes=(*args)
            super
            @model.name << @options[:name_suffix].to_s
          end
        end
      end

      it "creates new objects" do
        leader_form.attributes = {employees: [{name: 'new employee'}]}

        expect(leader.employees.size).to eq(1)
        expect(leader.employees[0].name).to eq('new employee')
      end

      it "sets ids for new objects" do
        leader_form.attributes = {employees: [{id: 15, name: 'new employee'}]}
        expect(leader.employees[0].id).to eq(15)
      end

      it "assigns properties to objects" do
        build :employee
        leader_form.attributes = {employees: [{id: employee.id, name: 'new name'}]}

        expect(leader.employees.size).to eq(1)
        expect(leader.employees[0].name).to eq('new name')
      end

      it "deletes old objects" do
        build :employee, :employee2
        leader_form.attributes = {employees: [{id: employee2.id}]}

        expect(leader.employees[0]).to be_marked_for_destruction
        expect(leader.employees[1]).not_to be_marked_for_destruction
      end

      it "skips if data is nil" do
        build :employee
        leader_form.attributes = {employees: nil}
        expect(leader.employees).to eq([employee])
      end

      it "passes options to child forms" do
        leader_form = employee_form_class.new(leader, name_suffix: ' the great')
        leader_form.attributes = {employees: [{name: 'new name'}]}
        expect(leader.employees[0].name).to eq('new name the great')
      end
    end

    context "embeds many association with embeded form" do
      before do
        employee_form_class.class_eval do
          embeds_many :employees do
            attributes :name
          end
        end
      end

      it "creates new objects" do
        leader_form.attributes = {employees: [{name: 'new employee'}]}

        expect(leader.employees.size).to eq(1)
        expect(leader.employees[0].name).to eq('new employee')
      end

      it "sets ids for new objects" do
        leader_form.attributes = {employees: [{id: 15, name: 'new employee'}]}
        expect(leader.employees[0].id).to eq(15)
      end

      it "assigns properties to objects" do
        build :employee
        leader_form.attributes = {employees: [{id: employee.id, name: 'new name'}]}

        expect(leader.employees.size).to eq(1)
        expect(leader.employees[0].name).to eq('new name')
      end
    end

    context "embeds one association with another form" do
      before do
        task_form_class = build(:task_form_class)
        task_form_class.class_eval do
          attributes :title

          def attributes=(*args)
            super
            @model.title << @options[:suffix].to_s
          end
        end
        employee_form_class.class_eval do
          embeds_one :task, task_form_class
        end
      end

      it "creates new objects" do
        leader_form.attributes = {task: {title: 'new task'}}

        expect(leader.task).to be_a(Task)
        expect(leader.task.title).to eq('new task')
      end

      it "assigns id to new object" do
        leader_form.attributes = {task: {id: 12, title: 'new task'}}
        expect(leader.task.id).to eq(12)
      end
      it "assigns object that already has been created" do
        build :do_laundry
        leader_form.update_attributes!(task: {id: do_laundry.id, title: 'new task'})
        expect(leader.task).to eq(do_laundry)
        expect(leader.task.title).to eq('new task')
        expect(Task.count).to eq(1)
      end

      it "changes what task is assigned" do
        build :task, :do_laundry
        leader_form.attributes = {task: {id: do_laundry.id}}
        expect(leader.task).to eq(do_laundry)
      end

      it "passes options to child forms" do
        leader_form = employee_form_class.new(leader, suffix: ' the great')
        leader_form.attributes = {task: {title: 'new title'}}
        expect(leader.task.title).to eq('new title the great')
      end
    end
  end

  describe "#update_attributes" do
    def perform(attributes)
      leader_form.update_attributes(attributes)
    end

    it_behaves_like 'saveable'
  end

  describe "#save" do
    def perform(attributes)
      leader_form.attributes = attributes
      leader_form.save
    end

    it_behaves_like 'saveable'
  end

  describe "#update_attributes!", raise: true do
    def perform(attributes)
      leader_form.update_attributes!(attributes)
    end

    it_behaves_like 'saveable'
  end

  describe "#save!", raise: true do
    def perform(attributes)
      leader_form.attributes = attributes
      leader_form.save!
    end

    it_behaves_like 'saveable'
  end
end
