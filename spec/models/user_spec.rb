# frozen_string_literal: true

RSpec.describe User do
  describe '#initialize' do
    context 'with username and password' do
      let(:user) { User.new(username: 'testuser', password: 'password123') }

      it 'creates a user with a username' do
        expect(user.username).to eq('testuser')
      end

      it 'generates a UUID for id' do
        expect(user.id).to be_a(String)
        expect(user.id).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/)
      end

      it 'sets created_at to current time' do
        expect(user.created_at).to be_within(1).of(Time.now)
      end
    end

    context 'with custom id' do
      let(:custom_id) { 'custom-id-123' }
      let(:user) { User.new(username: 'testuser', password: 'password123', id: custom_id) }

      it 'uses the provided id' do
        expect(user.id).to eq(custom_id)
      end
    end
  end

  describe '#authenticated?' do
    let(:user) { User.new(username: 'testuser', password: 'password123') }

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
    let(:user) { User.new(username: 'testuser', password: 'password123') }
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
    let(:user) { User.new(username: 'testuser', password: 'password123') }

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
    let(:user) { User.new(username: 'testuser', password: 'password123') }

    it 'provides read-only access to id' do
      expect(user).to respond_to(:id)
      expect(user).not_to respond_to(:id=)
    end

    it 'provides read-only access to username' do
      expect(user).to respond_to(:username)
      expect(user).not_to respond_to(:username=)
    end

    it 'provides read-only access to created_at' do
      expect(user).to respond_to(:created_at)
      expect(user).not_to respond_to(:created_at=)
    end

    it 'does not provide access to password_hash' do
      expect(user).not_to respond_to(:password_hash)
    end
  end
end
