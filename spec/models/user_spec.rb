require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { FactoryGirl.build(:user) }

  subject { user }

  context 'associations' do
    it { should have_many :members }
    it { should have_many :tenants }
  end

end
