# frozen_string_literal: true

RSpec.describe UserStore do
  subject { described_class.instance }

  let(:username) { 'test_user' }
  let(:password) { 'test_password' }

  before do
    stub_const(
      'ENV', {
        'USERNAME' => username,
        'PASSWORD' => password
      }
    )
  end

  describe 'initialization with default user' do
    it 'creates a default user from environment variables' do
      expect(subject.users.count).to be >= 1
      default_user = subject.find_by_username(username)
      expect(default_user).not_to be_nil
      expect(default_user.username).to eq(username)
    end
  end

  describe '#add_user' do
    it 'adds user to the store' do
      user = User.new(username: 'newuser', password: 'newpass')
      expect { subject.add_user(user) }.to change { subject.users.count }.by(1)
      expect(subject.find_by_username('newuser')).to eq(user)
    end
  end

  describe '#find_by_username' do
    let(:user) { User.new(username: 'findme', password: 'password') }

    before do
      subject.add_user(user)
    end

    it 'returns user when found' do
      expect(subject.find_by_username('findme')).to eq(user)
    end

    it 'returns nil when not found' do
      expect(subject.find_by_username('notfound')).to be_nil
    end
  end

  describe '#users' do
    it 'returns array of all users' do
      users = subject.users
      expect(users).to be_an(Array)
      expect(users).not_to be_empty
    end

    it 'includes the default user' do
      default_username = ENV.fetch('USERNAME', 'admin')
      usernames = subject.users.map(&:username)
      expect(usernames).to include(default_username)
    end
  end
end
