shared_examples 'saveable' do
  before do
    build :leader_form
    employee_form_class.class_eval do
      attributes :name, :monthly_pay
    end
  end

  def define_after_save
    employee_form_class.class_eval do
      def after_save
        @model.monthly_pay = 4321
      end
    end
  end

  context "valid" do
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
  end

  context "invalid" do
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
    else
      it "returns false" do
        expect(perform_invalid).to be_falsey
      end

      it "doesn't call after save" do
        define_after_save
        perform_invalid
        expect(leader.changes).to eq({"name" => ["Leader", nil]})
      end
    end
  end
end
