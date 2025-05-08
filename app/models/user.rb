# frozen_string_literal: true

class User < ApplicationRecord
  include Streakable::User
  include ActivityTrackable::User

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :workouts, dependent: :destroy
  has_many :exercises, dependent: :destroy
  has_many :sets, class_name: 'Allset', dependent: :destroy
  has_many :active_friendships,
           -> { where(confirmed: true) },
           class_name: 'Friend',
           foreign_key: 'user',
           dependent: :destroy
  has_many :passive_friendships,
           -> { where(confirmed: true) },
           class_name: 'Friend',
           foreign_key: 'follows',
           dependent: :destroy
  has_many :following,
           through: :active_friendships,
           source: :followed
  has_many :followers,
           through: :passive_friendships,
           source: :follower

  # Validations
  validates :first_name, :last_name, :email,
            presence: true
  validates :email,
            uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role,
            presence: true,
            inclusion: { in: %w[user admin] }
  validates :first_name, :last_name,
            length: { minimum: 2 },
            format: { with: /\A[a-zA-Z]+\z/, message: 'only allows letters' }

  def admin?
    role == 'admin'
  end

  def user?
    role == 'user'
  end

  def name
    "#{first_name} #{last_name}"
  end

  def manually_end_workout
    unassigned_sets = sets.where(belongs_to_workout: nil)
    return if unassigned_sets.empty?

    workout = Workout.create(
      user_id: id,
      started_at: unassigned_sets.first.created_at,
      ended_at: unassigned_sets.last.created_at,
      title: generate_workout_title(unassigned_sets)
    )

    unassigned_sets.update_all(belongs_to_workout: workout.id)
  end

  private

  def generate_workout_title(sets)
    sets.map(&:exercise)
        .map(&:group)
        .uniq
        .join(', ')
        .reverse
        .sub(',', '& ')
        .reverse
  end
end
