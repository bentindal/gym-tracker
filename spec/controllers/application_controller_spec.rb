# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render plain: 'test'
    end
  end

  describe '#set_location' do
    it 'sets feed location when referrer includes /feed' do
      request.headers['HTTP_REFERER'] = 'http://test.host/feed'
      get :index
      expect(assigns(:location)).to eq('/feed')
    end

    it 'sets dashboard location when referrer includes /dashboard' do
      request.headers['HTTP_REFERER'] = 'http://test.host/dashboard'
      get :index
      expect(assigns(:location)).to eq('/dashboard')
    end

    it 'sets user view location when referrer includes /users/view' do
      request.headers['HTTP_REFERER'] = 'http://test.host/users/view?id=123'
      get :index
      expect(assigns(:location)).to eq('/users/view?id=123')
    end

    it 'does not set location when referrer is not recognized' do
      request.headers['HTTP_REFERER'] = 'http://test.host/other'
      get :index
      expect(assigns(:location)).to be_nil
    end

    it 'does not set location when referrer is nil' do
      request.headers['HTTP_REFERER'] = nil
      get :index
      expect(assigns(:location)).to be_nil
    end
  end

  describe '#github_codespaces?' do
    it 'returns true when CODESPACES env is true' do
      allow(ENV).to receive(:[]).with('CODESPACES').and_return('true')
      expect(controller.send(:github_codespaces?)).to be true
    end

    it 'returns true when request base url includes github.dev' do
      allow(controller).to receive_message_chain(:request, :base_url).and_return('https://something.github.dev')
      expect(controller.send(:github_codespaces?)).to be true
    end

    it 'returns false when neither condition is met' do
      allow(ENV).to receive(:[]).with('CODESPACES').and_return(nil)
      allow(controller).to receive_message_chain(:request, :base_url).and_return('https://example.com')
      expect(controller.send(:github_codespaces?)).to be false
    end
  end
end 