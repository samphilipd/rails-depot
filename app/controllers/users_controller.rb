class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users
  # GET /users.json
  def index
    @users = User.order(:name)
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to users_url, notice: "User #{@user.name} was successfully created."}
        format.json { render action: 'show', status: :created, location: @user }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  # modify to require that user re-enter current password before allowing user to change it
  def update
    current_password = params[:user].delete(:current_password)
    @user.errors.add(:current_password, 'is not correct') unless @user.authenticate(current_password)
    respond_to do |format|
      if @user.errors.empty? && @user.update(user_params)
        format.html { redirect_to users_url, notice: "User #{@user.name} was successfully updated."}
        format.json { head :no_content }
      else
        format.html { render action: 'edit', notice: 'Unable to update user details, did you enter your current password correctly?' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    begin
      @user.destroy
      flash[:notice] = "User #{@user.name} deleted"
    rescue StandardError => e
      flash[:notice] = e.message # user cannot be deleted if that would leave no admins remaining, see User model (user.rb)
    end
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User deleted' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :password, :password_confirmation)
    end
end
