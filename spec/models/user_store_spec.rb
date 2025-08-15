# frozen_string_literal: true

require 'spec_helper'

RSpec.describe UserStore do
  let(:store) { UserStore.instance }

  describe 'singleton behavior' do
    it 'returns the same instance' do
      store1 = UserStore.instance
      store2 = UserStore.instance
      expect(store1).to be(store2)
    end

    it 'does not allow direct instantiation' do
      expect { UserStore.new }.to raise_error(NoMethodError)
    end
  end

  describe 'initialization with default user' do
    it 'creates a default user from environment variables' do
      expect(store.users_count).to be >= 1
      default_user = store.find_by_username(ENV.fetch('USERNAME', 'admin'))
      expect(default_user).not_to be_nil
      expect(default_user.username).to eq(ENV.fetch('USERNAME', 'admin'))
    end

    it 'allows authentication with default credentials' do
      username = ENV.fetch('USERNAME', 'admin')
      password = ENV.fetch('PASSWORD', 'password')
      expect(store.authenticate(username, password)).to be true
    end
  end

  describe '#add_user' do
    let(:user) { User.new(username: 'newuser', password: 'newpass') }

    before do
      # Clear any existing users except default
      store.instance_variable_get(:@users).clear
      store.instance_variable_get(:@users_by_username).clear
      store.send(:initialize_default_user)
    end

    it 'adds user to the store' do
      initial_count = store.users_count
      store.add_user(user)
      expect(store.users_count).to eq(initial_count + 1)
    end

    it 'makes user findable by username' do
      store.add_user(user)
      expect(store.find_by_username('newuser')).to eq(user)
    end

    it 'makes user findable by id' do
      store.add_user(user)
      expect(store.find_by_id(user.id)).to eq(user)
    end

    it 'returns the added user' do
      returned_user = store.add_user(user)
      expect(returned_user).to eq(user)
    end
  end

  describe '#find_by_username' do
    let(:user) { User.new(username: 'findme', password: 'password') }

    before do
      store.add_user(user)
    end

    it 'returns user when found' do
      expect(store.find_by_username('findme')).to eq(user)
    end

    it 'returns nil when not found' do
      expect(store.find_by_username('notfound')).to be_nil
    end
  end

  describe '#find_by_id' do
    let(:user) { User.new(username: 'findme', password: 'password') }

    before do
      store.add_user(user)
    end

    it 'returns user when found' do
      expect(store.find_by_id(user.id)).to eq(user)
    end

    it 'returns nil when not found' do
      expect(store.find_by_id('non-existent-id')).to be_nil
    end
  end

  describe '#user_exists?' do
    let(:user) { User.new(username: 'existinguser', password: 'password') }

    before do
      store.add_user(user)
    end

    it 'returns true for existing user' do
      expect(store.user_exists?('existinguser')).to be true
    end

    it 'returns false for non-existing user' do
      expect(store.user_exists?('nonexistinguser')).to be false
    end
  end

  describe '#authenticate' do
    let(:user) { User.new(username: 'authuser', password: 'authpass') }

    before do
      store.add_user(user)
    end

    it 'returns true for valid credentials' do
      expect(store.authenticate('authuser', 'authpass')).to be true
    end

    it 'returns false for invalid username' do
      expect(store.authenticate('wronguser', 'authpass')).to be false
    end

    it 'returns false for invalid password' do
      expect(store.authenticate('authuser', 'wrongpass')).to be false
    end

    it 'returns false for non-existent user' do
      expect(store.authenticate('nonexistent', 'password')).to be false
    end
  end

  describe '#users' do
    it 'returns array of all users' do
      users = store.users
      expect(users).to be_an(Array)
      expect(users).not_to be_empty
    end

    it 'includes the default user' do
      default_username = ENV.fetch('USERNAME', 'admin')
      usernames = store.users.map(&:username)
      expect(usernames).to include(default_username)
    end
  end

  describe '#users_count' do
    it 'returns the number of users' do
      count = store.users_count
      expect(count).to be_a(Integer)
      expect(count).to be >= 1 # At least the default user
    end
  end

  describe 'thread safety' do
    it 'uses Concurrent::Hash for thread-safe operations' do
      users_hash = store.instance_variable_get(:@users)
      users_by_username_hash = store.instance_variable_get(:@users_by_username)

      expect(users_hash).to be_a(Concurrent::Hash)
      expect(users_by_username_hash).to be_a(Concurrent::Hash)
    end
  end
end
