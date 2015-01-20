shared_examples 'saveable' do
  before do
    build :leader_form
    employee_form_class.class_eval do
      attributes :name, :monthly_pay
    end
  end

  it "assigns attributes to object" do
    perform_valid
    expect(leader.name).to eq('new name')
  end

  it "saves the object" do
    perform_valid
    expect(leader.reload.name).to eq('new name')
  end

  it "returns false if object is not saved" do
    expect(perform_invalid).to be_falsey
  end
end

shared_examples 'saveable!' do
  before do
    build :leader_form
    employee_form_class.class_eval do
      attributes :name, :monthly_pay
    end
  end

  it "assigns attributes to object" do
    perform_valid
    expect(leader.name).to eq('new name')
  end

  it "saves the object" do
    perform_valid
    expect(leader.reload.name).to eq('new name')
  end

  it "raises an error if object is not saved" do
    expect {
      perform_invalid
    }.to raise_error(ActiveRecord::RecordInvalid)
  end
end
