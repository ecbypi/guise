require 'spec_helper'

describe Guise do
  let!(:user) { create(:user) }
  let!(:supervisor) { create(:supervisor) }
  let!(:technician) { create(:technician) }

  after do
    User.delete_all
    UserRole.delete_all
  end

  describe ".has_guises" do
    it "sets up has_many association" do
      expect(user).to have_many :user_roles
    end

    it "adds scopes for each type" do
      technicians = User.technicians

      expect(technicians).to include technician
      expect(technicians).not_to include user
      expect(technicians).not_to include supervisor
    end

    it 'handles non-standard table names and foreign key attributes' do
      person = create(:person)
      create(:permission, person: person)

      expect(person).to have_many :permissions
      expect(Person.admins).to include person
    end
  end

  describe "#has_guise?" do
    it "checks if record is of the specified type" do
      expect(user).not_to have_guise :technician

      expect(technician).to have_guise :technician
      expect(technician).to have_guise :Technician
      expect(technician).to have_guise 'Technician'
      expect(technician).to have_guise 'technician'
      expect(technician).to have_guise Technician
    end

    it "raises an error if type was not specified" do
      expect { user.has_guise?(:Accountant) }.to raise_error ArgumentError
    end

    it 'ignores records marked for destruction' do
      technician_role = build(:user_role, name: 'Technician')
      technician_user = create(:user, user_roles: [technician_role])

      expect(technician_user).to have_guise :technician

      technician_role.mark_for_destruction
      expect(technician_user).not_to have_guise :technician
    end

    it 'is aliased based on the name of the association' do
      expect(user).not_to have_user_role :technician
      expect(technician).to have_user_role :technician
    end

    it 'is wrapped for each guise specified' do
      expect(user).not_to be_technician
      expect(technician).to be_technician
    end
  end

  describe "#has_guises?" do
    before do
      @role = create(:user_role, name: 'Technician', user: supervisor)
    end

    after do
      @role.destroy
    end

    it "checks if resource is all of the provided types" do
      expect(technician).not_to have_guises :Supervisor, :Technician
      expect(supervisor).to have_guises :Supervisor, :Technician
    end

    it 'ignores records marked for destruction' do
      technician_role = build(:user_role, name: 'Technician')
      supervisor_role = build(:user_role, name: 'Supervisor')
      user = create(:user, user_roles: [technician_role, supervisor_role])

      expect(user).to have_guises :technician, :supervisor

      technician_role.mark_for_destruction

      expect(user).not_to have_guises :technician, :supervisor
      expect(user).not_to have_guises :technician
      expect(user).to have_guises :supervisor
    end

    it 'is aliased based on the association name' do
      expect(technician).not_to have_user_roles :Supervisor, :Technician
      expect(supervisor).to have_user_roles :Supervisor, :Technician
    end
  end

  describe "#has_any_roles?" do
    it "checks if resource is any of the supplied roles" do
      expect(user).not_to have_any_guises :Supervisor, :Technician
      expect(technician).to have_any_guises 'supervisor', 'technician'
    end

    it 'ignores records marked for destruction' do
      technician_role = build(:user_role, name: 'Technician')
      technician_user = create(:user, user_roles: [technician_role])

      expect(technician_user).to have_any_guises :technician, :supervisor

      technician_role.mark_for_destruction
      expect(technician_user).not_to have_any_guises :technician, :supervisor
    end

    it 'is aliased based on the association name' do
      expect(user).not_to have_any_user_roles :Supervisor, :Technician
      expect(technician).to have_any_user_roles 'supervisor', 'Technician'
    end
  end

  describe '.guise_of' do
    it "sets default scope to limit to records of the class's type" do
      technician_ids = Technician.pluck(:id)

      expect(technician_ids).to eq [technician.id]
    end

    it 'sets up lifecycle callbacks to ensure records are initialized and created with the correct associated records' do
      new_record = Technician.new
      expect(new_record).to have_guise :technician

      created_record = Technician.create!
      expect(created_record).to have_guise :technician
    end
  end

  describe ".guise_for" do
    subject { UserRole.new }

    it "sets up belongs_to" do
      should belong_to(:user)
    end

    it 'defines scopes for each guise' do
      technician_role = create(:technician_role)
      supervisor_role = create(:supervisor_role)

      technician_roles = UserRole.technicians

      expect(technician_roles).to include technician_role
      expect(technician_roles).not_to include supervisor_role

      supervisor_roles = UserRole.supervisors

      expect(supervisor_roles).to include supervisor_role
      expect(supervisor_roles).not_to include technician_role
    end

    describe "adds validations to ensure guise attribute is" do
      it "present" do
        should validate_presence_of(:name)
      end

      it "unique per resource" do
        should validate_uniqueness_of(:name).scoped_to(:user_id)
      end

      it "is one of the guise names provided" do
        expect { create(:user_role, name: 'Farmer') }.to raise_error ActiveRecord::RecordInvalid
      end
    end
  end

  describe '.scoped_guise_of' do
    it 'sets default scope' do
      names = TechnicianUserRole.pluck(:name).uniq

      expect(names).to eq ['Technician']
    end

    it 'sets up lifecycle callbacks to ensure the object is in the correct state' do
      new_technician_role = TechnicianUserRole.new
      created_technician_role = TechnicianUserRole.create!

      expect(new_technician_role.name).to eq 'Technician'
      expect(created_technician_role.name).to eq 'Technician'
    end
  end
end
