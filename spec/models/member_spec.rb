require 'rails_helper'

RSpec.describe Member, type: :model do
  let(:member) do
    FactoryGirl.build(:member,
      user: FactoryGirl.build(:user),
      tenant: FactoryGirl.build(:tenant)
    )
  end

  subject { member }

  context 'associations' do
    it { should belong_to :user }
    it { should belong_to :tenant }
  end
end
