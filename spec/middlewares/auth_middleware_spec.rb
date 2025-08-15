# frozen_string_literal: true

RSpec.describe AuthMiddleware do
  let(:app) { ->(_env) { [200, {}, ['success']] } }
  let(:expected_unauthorized_response) do
    [401, { 'Content-Type' => 'application/json' }, [JSON.generate({ error: 'Unauthorized' })]]
  end

  # This is just to make sure I get the actual same user instance than the actual code.
  # Otherwise ids might be different.
  let(:user_store) { UserStore.instance }
  let(:user) { user_store.users.first }

  subject { AuthMiddleware.new(app, strategy: strategy) }

  describe '#call' do
    context 'when using the JWT strategy' do
      let(:strategy) { AuthStrategies::JWTAuth.new }

      context 'when token is valid' do
        let(:valid_token) { strategy.generate_token(user) }
        let(:env) { { 'HTTP_AUTHORIZATION' => "Bearer #{valid_token}" } }

        it 'sets the current_user and calls the next app' do
          response = subject.call(env)
          expect(env['current_user'].id).to eq(user.id)
          expect(response).to eq([200, {}, ['success']])
        end
      end

      context 'when token is invalid' do
        context 'with malformed JWT token' do
          let(:invalid_token) { 'invalid.jwt.token' }
          let(:env) { { 'HTTP_AUTHORIZATION' => "Bearer #{invalid_token}" } }

          it 'returns unauthorized response' do
            response = subject.call(env)
            expect(response).to match(expected_unauthorized_response)
          end
        end

        context 'with expired JWT token' do
          let(:expired_token) do
            token = nil
            Timecop.travel(Time.now - (strategy.expiration + 1)) do
              token = strategy.generate_token(user)
            end
            token
          end
          let(:env) { { 'HTTP_AUTHORIZATION' => "Bearer #{expired_token}" } }

          it 'returns unauthorized response' do
            response = subject.call(env)
            expect(response).to match(expected_unauthorized_response)
          end
        end
      end

      context 'without Authorization header' do
        let(:env) { {} }

        it 'returns unauthorized response' do
          response = subject.call(env)
          expect(response).to match(expected_unauthorized_response)
        end

        it 'returns unauthorized error message' do
          response = subject.call(env)
          expect(response).to match(expected_unauthorized_response)
        end
      end

      context 'with non-Bearer authorization' do
        let(:env) { { 'HTTP_AUTHORIZATION' => 'Basic dXNlcjpwYXNz' } }

        it 'returns returns unauthorized response' do
          response = subject.call(env)
          expect(response).to match(expected_unauthorized_response)
        end
      end

      context 'with empty Bearer token' do
        let(:env) { { 'HTTP_AUTHORIZATION' => 'Bearer ' } }

        it 'returns returns unauthorized response' do
          response = subject.call(env)
          expect(response).to match(expected_unauthorized_response)
        end
      end
    end
  end
end
