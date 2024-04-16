# app/controllers/service_worker_controller.rb
class ServiceWorkerController < ApplicationController
    protect_from_forgery except: :service_worker
    skip_before_action :authenticate_user!

    def service_worker
    end
    
    def manifest
    end
end