class UsersController < ApplicationController
  before_action :set_user, only: %i[ show update destroy ]

  # GET /users
  def index
    @users = User.all

    render json: @users
  end

  # GET /users/1
  def show
    render json: @user
  end

  # POST /users
  def create
    user = User.create!(email: params[:email], password: params[:password])
    render json: user
  end

  def login
    user = User.find_by!(email: params[:email]).try(:authenticate, params[:password])
    if user
      token = generate_token(user.id)
      render json: { user: user, token: token }
    else
      render json: { error: "Invalid Password"}
    end
  end

  def profile
    token = request.headers["token"]
    user_id = decode_token(token)
    user = User.find(user_id)
    if user
      render json: user
    else
      render json: { error: "User not found" }, status: 404
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit(:email, :password_digest)
    end
end
