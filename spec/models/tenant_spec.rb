require 'rails_helper'

RSpec.describe Tenant, type: :model do
  let(:tenant) { FactoryGirl.build(:tenant) }

  subject { tenant }

  context 'associations' do
    it { should have_many :members }
  end
end
