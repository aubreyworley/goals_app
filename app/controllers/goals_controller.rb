class GoalsController < ApplicationController
  before_filter :authorize, except: [:index, :show]
  
  # show All goals in our db
  def index
    @goals = Goal.all
    render :index
  end

  # form to create new goal that belongs to current_user
  def new
    @goal = Goal.new
    render :new
  end

  # creates new recipe in db that belongs to current_user
  def create
    goal = current_user.goals.create(goal_params)
    redirect_to goal_path(goal)
  end

  def show
    @goal = Goal.find(params[:id])
    render :show
  end

  def edit
    @goal = Goal.find(params[:id])
    if current_user.goals.include? @goal
    render :edit
    else
      redirect_to profile_path
    end
  end

  def update
    goal = Goal.find(params[:id])
    if current_user.goals.include? goal
      goal.update_attributes(goal_params)
      redirect_to goal_path(goal)
    else 
      redirect_to profile_path
    end
  end

  def destroy
    goal = Goal.find(params[:id])
    if current_user.goals.include? goal
      goal.delete_attributes(goal_params)
      redirect_to goal_path(goal)
    else 
      redirect_to profile_path
    end
  end

  private
    def goal_params
      params.require(:goal).permit(:description, :time_to_complete)
    end
end

