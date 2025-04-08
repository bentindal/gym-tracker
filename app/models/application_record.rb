# frozen_string_literal: true

# The ApplicationRecord serves as the base class for all models in the application.
# It provides shared functionality and acts as an abstract class.
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
