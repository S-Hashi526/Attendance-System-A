class SessionsController < ApplicationController
  before_action :logged_in_not_access, only: :new

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      # ログイン
      log_in user

      # ログイン情報を記憶するかしないか
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)

      # 管理者であればユーザー一覧画面に遷移可
      if current_user.admin?
        redirect_to users_url
      else
        redirect_back_or user
      end

      # ユーザー情報ページにリダイレクト
      # redirect_back_or user

    else
      flash.now[:danger] = '認証に失敗しました。'
      render :new
    end
  end

  def destroy
    # ログイン中の場合のみログアウト可能
    log_out if logged_in?
    flash[:success] = 'ログアウトしました。'
    redirect_to root_url
  end
end