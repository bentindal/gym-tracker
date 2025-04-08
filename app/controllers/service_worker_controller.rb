# frozen_string_literal: true

# The ServiceWorkerController serves static files for the service worker and manifest.
# It ensures these files are accessible without requiring user authentication.
class ServiceWorkerController < ApplicationController
  protect_from_forgery except: :service_worker
  skip_before_action :authenticate_user!

  def service_worker
    respond_to do |format|
      format.js do
        render file: Rails.public_path.join('service-worker.js'), content_type: 'application/javascript'
      end
    end
  end

  def manifest
    respond_to do |format|
      format.json { render file: Rails.public_path.join('manifest.json'), content_type: 'application/json' }
    end
  end
end
