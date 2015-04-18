require 'spec_helper'

describe Guise do
  let!(:user) { User.create!(email: "bob@bob.bob") }
  let!(:supervisor) { Supervisor.create!(email: "jane@manag.er") }
  let!(:technician) { Technician.create!(email: "sarah@fix.it") }

  def self.active_record_has_pluck_and_not_version_4_0?
    ActiveRecord::VERSION::STRING >= "4.1" ||
      ActiveRecord::VERSION::STRING <= "3.2" &&
      ActiveRecord::Relation.method_defined?(:pluck)
  end

  after do
    User.delete_all
    UserRole.delete_all
  end

  describe ".has_guises" do
    it "sets up has_many association" do
      reflection = User.reflect_on_association(:user_roles)

      expect(reflection).not_to be_nil
    end

    it "adds scopes for each type" do
      technicians = User.technicians.map(&:id)

      expect(technicians).to include technician.id
      expect(technicians).not_to include user.id
      expect(technicians).not_to include supervisor.id
    end

    shared_examples(
      "building and saving associated records"
    ) do |source, strategy|
      it "sets up scopes to correctly create associated records" do
        technician = source.public_send(strategy)

        expect(technician).to be_technician
        expect(technician.user_roles.map(&:name)).to eq ["Technician"]

        if technician.new_record?
          technician.save!

          expect(technician.reload).to be_technician
        end
      end
    end

    include_examples(
      "building and saving associated records",
      User.technicians,
      :new
    )

    include_examples(
      "building and saving associated records",
      User.technicians,
      :create
    )

    include_examples(
      "building and saving associated records",
      Technician,
      :new
    )

    include_examples(
      "building and saving associated records",
      Technician,
      :create
    )

    if active_record_has_pluck_and_not_version_4_0?
      it "sets up scopes to correctly handle `ActiveRecord::Relation#pluck`" do
        expect(Technician.all.pluck(:id)).to eq [technician.id]
      end
    end

    it 'aliases the association methods to `guise=` and `guises=`' do
      record = User.create!

      expect(record.guises).to eq []

      # NOTE: The user is assigned to deal with a Rails 3.1 issue
      record.guises = [UserRole.new(name: "Technician", user: record)]
      record.guises << UserRole.new(name: "Supervisor", user: record)

      expect(record.guises(true).length).to eq 2

      expect(record.guise_ids.length).to eq 2

      record.guise_ids = []

      expect(record.guises.length).to eq 0
    end

    it 'handles non-standard table names and foreign key attributes' do
      person = Person.create!
      Permission.create!(person: person, privilege: "Admin")
      reflection = Person.reflect_on_association(:permissions)

      expect(reflection).not_to be_nil
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
      technician_role = UserRole.new(name: "Technician")
      technician_user = User.create(user_roles: [technician_role])

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
      @role = UserRole.create!(name: "Technician", user: supervisor)
    end

    after do
      @role.destroy
    end

    it "checks if resource is all of the provided types" do
      expect(technician).not_to have_guises :Supervisor, :Technician
      expect(supervisor).to have_guises :Supervisor, :Technician
    end

    it 'ignores records marked for destruction' do
      technician_role = UserRole.new(name: "Technician")
      supervisor_role = UserRole.new(name: "Supervisor")
      user = User.create!(user_roles: [technician_role, supervisor_role])

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

  describe "#has_any_guises?" do
    it "checks if resource is any of the supplied roles" do
      expect(user).not_to have_any_guises :Supervisor, :Technician
      expect(technician).to have_any_guises 'supervisor', 'technician'
    end

    it 'ignores records marked for destruction' do
      technician_role = UserRole.new(name: "Technician")
      technician_user = User.create!(user_roles: [technician_role])

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
      technician_ids = Technician.all.map(&:id)

      expect(technician_ids).to eq [technician.id]
    end

    it 'sets up lifecycle callbacks to ensure records are initialized and created with the correct associated records' do
      new_record = Technician.new
      expect(new_record).to have_guise :technician

      created_record = Technician.create!
      expect(created_record).to have_guise :technician

      # Ensure `after_initialize` only runs when the record hasn't been persisted.
      existing_record = Technician.find(technician.id)
      expect(existing_record.guises.length).to eq 1
    end

    it 'sets default scope to ensure records are not readonly' do
      expect(Technician.first).not_to be_readonly
    end

    it 'raises an error if no guises are registered for the class' do
      expect do
        Class.new(ActiveRecord::Base) do
          guise_of :Model
        end
      end.to raise_error Guise::DefinitionNotFound
    end
  end

  describe ".guise_for" do
    it "sets up belongs_to" do
      reflection = UserRole.reflect_on_association(:user)

      expect(reflection).not_to be_nil
    end

    it 'defines scopes for each guise' do
      technician_role = UserRole.create(name: "Technician")
      supervisor_role = UserRole.create(name: "Supervisor")

      technician_roles = UserRole.technicians

      expect(technician_roles).to include technician_role
      expect(technician_roles).not_to include supervisor_role

      supervisor_roles = UserRole.supervisors

      expect(supervisor_roles).to include supervisor_role
      expect(supervisor_roles).not_to include technician_role
    end

    it 'raises an error if no guises are registered for the class' do
      expect do
        Class.new(ActiveRecord::Base) do
          guise_for :Model
        end
      end.to raise_error Guise::DefinitionNotFound
    end

    it "adds validations to ensure presence, inclusion and uniqueness " \
      "of the guise attribute" do
      user_role = UserRole.new
      user_role.valid?

      expect(user_role.errors[:name]).to match_array [
        I18n.t("errors.messages.blank"),
        I18n.t("errors.messages.inclusion")
      ]

      user_role.user = technician
      user_role.name = "Technician"
      user_role.valid?

      expect(user_role.errors[:name]).to eq [
        I18n.t(
          "activerecord.errors.messages.taken",
          default: :"errors.messages.taken"
        )
      ]
    end
  end

  describe '.scoped_guise_of' do
    it 'sets default scope' do
      names = TechnicianUserRole.all.map(&:name).uniq

      expect(names).to eq ['Technician']
    end

    it 'sets up lifecycle callbacks to ensure the object is in the correct state' do
      new_technician_role = TechnicianUserRole.new
      created_technician_role = TechnicianUserRole.create!

      expect(new_technician_role.name).to eq 'Technician'
      expect(created_technician_role.name).to eq 'Technician'
    end

    it 'raises an error if no guises are registered for the class' do
      expect do
        Class.new(ActiveRecord::Base) do
          scoped_guise_for :Model
        end
      end.to raise_error Guise::DefinitionNotFound
    end
  end
end
