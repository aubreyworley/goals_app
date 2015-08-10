1. (terminal) rails new goals_app -T -d postgresql
2. (terminal) cd goals_app
3. (terminal) rake db: create
4. (terminal) subl .
5. (sublime) routes.rb: 

# add routes for users, sessions, & goals

Rails.application.routes.draw do

  # users routes
  get "/signup", to: "users#new"
  get "/profile", to: "users#show"
  resources :users, only: [:create]

  # sessions routes
  get "/login", to: "sessions#new"
  get "/logout", to: "sessions#destroy"
  # post "/sessions", to: "sessions#create" 
  resources :sessions, only: [:create]


  # goals routes
  resources :goals, except: [:index]

  root "goals#index"
end

6. (terminal) rake routes
7. (terminal: create users controller) rails g controller users new create show
8. (sublime) delete the new, create, show routes in routes.rb
9. (users_controller.rb: label routes)
10.(terminal) rails s
11. (browser) localhost: 3000
12. (terminal) rails g model User first_name last_name email password_digest
13. (terminal) rails g model Goal description time_to_complete
14. (sublime) user.rb: has_many :goals, dependent: :destroy
15. (sublime) goal.rb: belongs_to :user
16. (sublime) create_goals.rb: t.belongs_to :user
17. (terminal) rake db:migrate
18. (sublime) schema.rb
19. (sublime) user.rb: has_secure_password
20. (sublime) Gemfile: uncomment: gem 'bcrypt', '~> 3.1.7'
21. (temrinal) bundle
22. (terminal) rails c
23. (terminal) u = User.create(email: "test@test.com", password: "password")
24. (terminal) u.goals
25. (sublime) new.html.erb: add Sign-up form
26. users_controller.rb: 

#form to create new user
  def new
    @user = User.new
    render :new
  end

  # creates new user in db
  def create
    user = User.new(user_params)
    if user.save
      session[:user_id] = user.id
      redirect_to profile_path
    else
      redirect_to signup_path
    end
  end

  # show current_user
  def show
     @current_user = User.find(session[:user_id])
    render :show
  end

  private
    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :password)
    end

27. show.html.erb

<h1>Profile Page</h1>
<div>
  <p><%= @current_user.first_name %></p>
  <p><%= @current_user.last_name %></p>
  <p><%= @current_user.email %></p>
</div>
<h3>My Goals</h3>
<%= @current_user.goals %>

28. (terminal) rails g controller sessions new create destroy

29. (s) sessions_controller.rb

  # login form
  def new
  end

  # authenticate the user, set session, redirect
  def create
  end

  # clear session (log out user)
  def destroy
  end

30. (Browser) localhost:3000/login
31. (s) sessions- new.html.erb

<h1>Log In</h1>
<%= form_for :user, url: sessions_path do |f| %>
  <%= f.email_field :email, placeholder: "Email" %><br>
  <%= f.password_field :password, placeholder: "Password" %><br>
  <%= f.submit "Log In" %>
<% end %>

32. routes.rb

# users routes
  get "/signup", to: "users#new"
  get "/profile", to: "users#show"
  resources :users, only: [:create]

  # sessions routes
  get "/login", to: "sessions#new"
  get "/logout", to: "sessions#destroy"
  resources :sessions, only: [:create]
  post "/sessions", to: "sessions#create" 

  # goals routes
  resources :goals, except: [:index]

  root "goals#index"

  33. sessions_controller.rb

# login form
  def new
    render :new
  end

  # authenticate the user, set session, redirect
  def create
    user = User.find_by_email(user_params[:email])
    if user && user.authenticate(user_params[:password])
      session[:user_id] = user.id
      redirect_to profile_path
    else
      redirect_to login_path
    end
  end

  # clear session (log out user)
  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end

  private 
    def user_params
      params.require(:user).permit(:email, :password)
    end

34. application_controller.rb

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  helper_method :current_user

  def authorize
    unless current_user
      redirect_to login_path
    end
  end

end

35. users_controller.rb

#refactor show

# show current_user
  def show
    render :show
  end

36. show.html.erb

#refactor @current_user to match application controller

<h1>Profile Page</h1>
<div>
  <p><%= current_user.first_name %></p>
  <p><%= current_user.last_name %></p>
  <p><%= current_user.email %></p>
</div>
<h3>My Goals</h3>
<%= current_user.goals %>

37. (browser) localhost:3000/login

#test that works as same as before refactor

38. users_controller.rb

before_filter :authorize, only: [:show]
  
  #form to create new user
  def new
    if current_user
      redirect_to profile_path
    else
      @user = User.new
      render :new
    end
  end

# block user from signing up again if logged in
  # creates new user in db
  def create
    if current_user
      redirect_to profile_path
    else
      user = User.new(user_params)
      if user.save
        session[:user_id] = user.id
        redirect_to profile_path
      else
        redirect_to signup_path
      end
    end
  end

  # show current_user
  def show
    render :show
  end

  private
    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :password)
    end

39. sessions_controller.rb

#refactor
  # login form
  def new
    if current_user
      redirect_to profile_path
    else
      render :new
    end
  end

40. (terminal) rails g controller goals index new create show edit update destroy

41. routes.rb: delete the new routes

42. goals_controller.rb

# show all goals in db

def index
  @goals = Goal.all
  render :index
end

43. index.html.erb

<h1>Goals</h1>
<hr>
<% @goals.each do |goal| %>
  <p><%= goal.description %> - <%= goal.time_to_complete %></p>
<% end %>

<% if current_user %>
  <%= link_to "Add Goal", new_goal_path %>
  <% end %>

44. goals_controller.rb

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

45. new.html.erb-goals

<h1>New Goal</h1>
<%= form_for @goal do |f| %>
  <%= f.text_field :description, placeholder: "Description" %><br>
  <%= f.text_field :time_to_complete, placeholder: "Desired Completion Date" %><br>
  <%= f.submit "Save Goal" %>
<% end %>

46. goals_controller.rb

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
    render :show
  end

  def edit
  end

  def update
  end

  def destory
  end

  private
    def goal_params
      params.require(:goal).permit(:description, :time_to_complete)
    end
end

47. show.html.erb-goals

<h1><%= @goal.description %></h1>
<hr>
<p><%= @goal.time_to_complete %></p>

48. goals_controller.rb

def show
    @goal = Goal.find(params[:id])
    render :show
  end

49. show.html.erb-users

<h1>Profile Page</h1>
<div>
  <p><%= current_user.first_name %></p>
  <p><%= current_user.last_name %></p>
  <p><%= current_user.email %></p>
</div>
<h3>My Goals</h3>
<% current_user.goals.each do |goal| %>
  <p><%= goal.description %> - <%= goal.time_to_complete %></p>
<% end %>

50. (browser) localhost:3000/profile
#check to see if goals updated with user

51. show.html.erb-users

#update for user w/ no goals

<h1>Profile Page</h1>
<div>
  <p><%= current_user.first_name %></p>
  <p><%= current_user.last_name %></p>
  <p><%= current_user.email %></p>
</div>

<%= if current_user.goals.any? %>
  <h3>My Goals</h3>
  <% current_user.goals.each do |goal| %>
    <p><%= goal.description %> - <%= goal.time_to_complete %></p>
  <% end %>
<% else %>
  <h4> You don't have any goals yet! </h4>
  <%= link_to "Add New Goal", new_goal_path %>
<% end %>

52. index.html.erb

<h1>Goals</h1>
<hr>
<% @goals.each do |goal| %>
  <p><%= goal.description %> - <%= goal.time_to_complete %> <%= link_to "View Goal", goal_path(goal)  %></p>
<% end %>

<% if current_user %>
  <%= link_to "Add New Goal", new_goal_path %>
  <% end %>

53. goals_controller.rb

def edit
    @goal = Goal.find(parms[:id])
    render :edit
  end

54. edit.html.erb

<h1>Edit Goal</h1>
<%= form_for @goal do |f| %>
  <%= f.text_field :description, placeholder: "Description" %><br>
  <%= f.text_field :time_to_complete, placeholder: "Desired Completion Date" %><br>
  <%= f.submit "Save Goal" %>
<% end %>

55. show.html.erb

<h1><%= @goal.description %></h1>
<hr>
<p><%= @goal.time_to_complete %></p>

<% if current_user && current_user.goals.include?(@goal) %>
  <p><%= link_to "Edit Goal", edit_goal_path(@goal) %>
<% end %>

56. goals_controller.rb

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







