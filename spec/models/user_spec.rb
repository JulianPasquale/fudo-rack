# frozen_string_literal: true

RSpec.describe User, type: :model do
  describe 'validations' do
    subject { build(:user) }
    
    it { should validate_presence_of(:username) }
    it { should validate_uniqueness_of(:username) }
    it { should validate_presence_of(:password).on(:create) }
  end

  describe '#create' do
    context 'with valid attributes' do
      let(:user) { create(:user, username: 'testuser') }

      it 'creates a user with a username' do
        expect(user.username).to eq('testuser')
      end

      it 'generates an auto-incrementing id' do
        expect(user.id).to be_a(Integer)
        expect(user.id).to be > 0
      end

      it 'sets created_at and updated_at' do
        expect(user.created_at).to be_within(1).of(Time.now)
        expect(user.updated_at).to be_within(1).of(Time.now)
      end

      it 'hashes the password' do
        expect(user.password_hash).to be_present
        expect(user.password_hash).not_to eq('password123')
      end
    end
  end

  describe '#authenticated?' do
    let(:user) { create(:user, username: 'testuser') }

    it 'returns true for correct password' do
      expect(user.authenticated?('password123')).to be true
    end

    it 'returns false for incorrect password' do
      expect(user.authenticated?('wrongpassword')).to be false
    end

    it 'returns false for nil password' do
      expect(user.authenticated?(nil)).to be false
    end

    it 'returns false for empty password' do
      expect(user.authenticated?('')).to be false
    end
  end

  describe '#to_h' do
    let(:user) { create(:user, username: 'testuser') }
    let(:hash) { user.to_h }

    it 'returns a hash with user attributes' do
      expect(hash).to include(
        id: user.id,
        username: 'testuser',
        created_at: user.created_at
      )
    end

    it 'does not include password information' do
      expect(hash).not_to have_key(:password)
      expect(hash).not_to have_key(:password_hash)
    end

    it 'returns a hash with symbol keys' do
      expect(hash.keys).to all(be_a(Symbol))
    end
  end

  describe '#to_json' do
    let(:user) { create(:user, username: 'testuser') }

    it 'returns a JSON string' do
      json_string = user.to_json
      expect(json_string).to be_a(String)

      parsed = JSON.parse(json_string)
      expect(parsed['username']).to eq('testuser')
      expect(parsed['id']).to eq(user.id)
    end

    it 'does not include password information in JSON' do
      json_string = user.to_json
      parsed = JSON.parse(json_string)

      expect(parsed).not_to have_key('password')
      expect(parsed).not_to have_key('password_hash')
    end
  end

  describe 'attribute access' do
    let(:user) { create(:user, username: 'testuser') }

    it 'provides access to id' do
      expect(user).to respond_to(:id)
      expect(user).to respond_to(:id=)
    end

    it 'provides access to username' do
      expect(user).to respond_to(:username)
      expect(user).to respond_to(:username=)
    end

    it 'provides access to created_at' do
      expect(user).to respond_to(:created_at)
      expect(user).to respond_to(:created_at=)
    end

    it 'provides access to password_hash' do
      expect(user).to respond_to(:password_hash)
    end
  end
end
