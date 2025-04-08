# frozen_string_literal: true

# app/controllers/service_worker_controller.rb
class ServiceWorkerController < ApplicationController
  protect_from_forgery except: :service_worker
  skip_before_action :authenticate_user!

  def service_worker
    respond_to do |format|
      format.js do
        render file: Rails.root.join('public', 'service-worker.js'), content_type: 'application/javascript'
      end
    end
  end

  def manifest
    respond_to do |format|
      format.json { render file: Rails.root.join('public', 'manifest.json'), content_type: 'application/json' }
    end
  end
end
