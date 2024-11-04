# app/controllers/service_worker_controller.rb
class ServiceWorkerController < ApplicationController
    protect_from_forgery except: :service_worker
    skip_before_action :authenticate_user!

    def service_worker
        respond_to do |format|
            format.js { render file: Rails.root.join('public', 'service_worker.js'), content_type: 'application/javascript' }
        end
    end
    
    def manifest
        respond_to do |format|
            format.json { render file: Rails.root.join('public', 'manifest.json'), content_type: 'application/json' }
        end
    end
end