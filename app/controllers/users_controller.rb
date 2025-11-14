class UsersController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  def new
    if User.unscoped_all.exists?
      redirect_to new_session_path, notice: "Admin user already exists. Please sign in."
    else
      @user = User.new
    end
  end

  def edit
    @user = Current.user
  end

  def update
    @user = Current.user
    if @user.update(user_params)
      redirect_to admin_posts_path, alert: "Account was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def create
    @user = User.new(user_params)
    @user.site = current_site  # 设置用户所属站点
    
    if @user.save
      # 自动登录新创建的用户
      start_new_session_for @user
      redirect_to admin_root_path, notice: "Admin user created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
  def user_params
    params.expect(user: [ :user_name, :password, :password_confirmation ])
  end
end
