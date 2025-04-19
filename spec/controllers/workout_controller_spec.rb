require 'rails_helper'

RSpec.describe WorkoutController, type: :controller do
  render_views
  
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:workout) { create(:workout, user: user) }

  before do
    sign_in user
  end

  describe "DELETE #destroy" do
    context "when user owns the workout" do
      it "soft deletes the workout and redirects to workout view" do
        expect {
          delete :destroy, params: { id: workout.id }
        }.to change { workout.reload.deleted_at }.from(nil)

        expect(response).to redirect_to("/workout/view?id=#{workout.id}")
        expect(flash[:notice]).to eq('Workout was successfully deleted.')
      end
    end

    context "when user does not own the workout" do
      before do
        sign_out user
        sign_in other_user
      end

      it "does not delete the workout and redirects to permission error" do
        expect {
          delete :destroy, params: { id: workout.id }
        }.not_to change { workout.reload.deleted_at }

        expect(response).to redirect_to("/error/permission")
      end
    end
  end

  describe "GET #view" do
    context "when workout is deleted" do
      before do
        workout.update(deleted_at: Time.current)
      end

      it "shows the deleted workout message" do
        get :view, params: { id: workout.id }
        expect(response).to be_successful
        expect(response.body).to include("Workout Deleted")
        expect(response.body).to include("Return to Dashboard")
      end

      it "does not show AI analysis" do
        create(:workout_analysis, 
          workout: workout, 
          feedback: "Test analysis",
          total_volume: 1000,
          total_sets: 10,
          total_reps: 100,
          average_weight: 50
        )
        get :view, params: { id: workout.id }
        expect(response.body).not_to include("AI Analysis")
      end
    end
  end
end 