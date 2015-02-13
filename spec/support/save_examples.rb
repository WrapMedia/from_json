shared_examples 'saveable' do
  before do
    build :leader_form
    employee_form_class.class_eval do
      attributes :name, :monthly_pay
      embeds_many :employees, self
    end
  end

  def define_after_save
    employee_form_class.class_eval do
      after_save do
        @model.monthly_pay = 4321
      end
    end
  end

  def define_before_save
    employee_form_class.class_eval do
      before_save do
        @model.monthly_pay = 9876
      end
    end
  end

  context "valid" do
    def perform_valid
      perform name: 'new name'
    end

    it "assigns attributes to object" do
      perform_valid
      expect(leader.name).to eq('new name')
    end

    it "saves the object" do
      perform_valid
      expect(leader.reload.name).to eq('new name')
    end

    it "calls after save" do
      define_after_save
      perform_valid
      expect(leader.changes).to eq('monthly_pay' => [nil, 4321])
    end

    it "calls before save" do
      define_before_save
      perform_valid
      expect(leader.reload.monthly_pay).to eq(9876)
    end

    it "calls save on associations" do
      build :employee
      perform employees: [{id: employee.id, name: 'new name'}]
      expect(leader.reload.employees.size).to eq(1)
      expect(leader.reload.employees[0].name).to eq('new name')
    end
  end

  context "invalid" do
    def perform_invalid
      perform name: nil
    end

    if metadata[:raise]
      it "raises an error" do
        expect {
          perform_invalid
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "doesn't call after save" do
        define_after_save
        expect { perform_invalid }.to raise_error
        expect(leader.changes).to eq({"name" => ["Leader", nil]})
      end

      it "raises an error if associations are not saved" do
        build :employee
        expect {
          perform employees: [{id: employee.id, name: nil}]
        }.to raise_error(ActiveRecord::RecordInvalid)

        begin
          perform employees: [{id: employee.id, name: nil}]
        rescue => e
          p e.record, e.message
        end

      end

      it "doesn't save child if parent can't be saved" do
        build :employee
        expect { perform name: nil, employees: [{id: employee.id, name: 'new name'}] }.to raise_error
        expect(employee.reload.name).to eq('Employee')
      end

      it "doesn't save parent if child can't be saved" do
        build :employee
        expect { perform name: 'new name', employees: [{id: employee.id, name: nil}] }.to raise_error
        expect(leader.reload.name).to eq('Leader')
      end
    else
      it "returns false" do
        expect(perform_invalid).to be_falsey
      end

      it "doesn't call after save" do
        define_after_save
        perform_invalid
        expect(leader.changes).to eq({"name" => ["Leader", nil]})
      end

      it "raises an error if associations are not saved" do
        build :employee
        expect(perform(employees: [{id: employee.id, name: nil}])).to be_falsey
      end

      it "doesn't save child if parent can't be saved" do
        build :employee
        perform name: nil, employees: [{id: employee.id, name: 'new name'}]
        expect(employee.reload.name).to eq('Employee')
      end

      it "doesn't save parent if child can't be saved" do
        build :employee
        perform name: 'new name', employees: [{id: employee.id, name: nil}]
        expect(leader.reload.name).to eq('Leader')
      end
    end
  end
end
