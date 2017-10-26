require 'rails_helper'

RSpec.describe Api::V1::StatusesController, type: :controller do
  render_views

  let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let(:app)   { Fabricate(:application, name: 'Test app', website: 'http://testapp.com') }
  let(:token) { double acceptable?: true, resource_owner_id: user.id, application: app }

  context 'with an oauth token' do
    before do
      allow(controller).to receive(:doorkeeper_token) { token }
    end

    describe 'GET #show' do
      let(:status) { Fabricate(:status, account: user.account) }

      it 'returns http success' do
        get :show, params: { id: status.id }
        expect(response).to have_http_status(:success)
      end
    end

    describe 'GET #context' do
      let(:status) { Fabricate(:status, account: user.account) }

      before do
        Fabricate(:status, account: user.account, thread: status)
      end

      it 'returns http success' do
        get :context, params: { id: status.id }
        expect(response).to have_http_status(:success)
      end
    end

    describe 'POST #create' do
      it 'returns http success' do
        post :create, params: { status: 'Hello world' }
        expect(response).to have_http_status(:success)
      end

      it 'returns http unprocessable entity when published parameter is invalid' do
        post :create, params: { status: 'Hello world', published: 'invalid' }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    describe 'DELETE #destroy' do
      let(:status) { Fabricate(:status, account: user.account) }

      before do
        post :destroy, params: { id: status.id }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'removes the status' do
        expect(Status.find_by(id: status.id)).to be nil
      end
    end
  end

  context 'without an oauth token' do
    before do
      allow(controller).to receive(:doorkeeper_token) { nil }
    end

    context 'with a private status' do
      let(:status) { Fabricate(:status, account: user.account, visibility: :private) }

      describe 'GET #show' do
        it 'returns http unautharized' do
          get :show, params: { id: status.id }
          expect(response).to have_http_status(:missing)
        end
      end

      describe 'GET #context' do
        before do
          Fabricate(:status, account: user.account, thread: status)
        end

        it 'returns http unautharized' do
          get :context, params: { id: status.id }
          expect(response).to have_http_status(:missing)
        end
      end

      describe 'GET #card' do
        it 'returns http unautharized' do
          get :card, params: { id: status.id }
          expect(response).to have_http_status(:missing)
        end
      end
    end

    context 'with a public status' do
      let(:status) { Fabricate(:status, account: user.account, visibility: :public) }

      describe 'GET #show' do
        it 'returns http success' do
          get :show, params: { id: status.id }
          expect(response).to have_http_status(:success)
        end
      end

      describe 'GET #context' do
        before do
          Fabricate(:status, account: user.account, thread: status)
        end

        it 'returns http success' do
          get :context, params: { id: status.id }
          expect(response).to have_http_status(:success)
        end
      end

      describe 'GET #card' do
        it 'returns http success' do
          get :card, params: { id: status.id }
          expect(response).to have_http_status(:success)
        end
      end
    end

    context 'with a public status but no track nor album' do
      let(:status) { Fabricate(:status, music: nil, visibility: :public) }

      it 'returns 404' do
        get :music, params: { id: status.id }
        expect(response).to have_http_status 404
      end
    end

    context 'with a public status and an album' do
      let(:album) { Fabricate(:album) }
      let(:status) { Fabricate(:status, music: album, visibility: :public) }

      it 'returns 404' do
        get :music, params: { id: status.id }
        expect(response).to have_http_status 404
      end
    end

    context 'with a public status and a track' do
      let(:track) { Fabricate(:track) }
      let(:status) { Fabricate(:status, music: track, visibility: :public) }

      describe 'GET #music' do
        it 'redirects to music' do
          get :music, params: { id: status.id }
          expect(response).to have_http_status 302
        end

        it 'increments view_count' do
          expect do
            get :music, params: { id: status.id }
            track.reload
          end.to change { track.view_count }.by 1
        end
      end
    end
  end
end
