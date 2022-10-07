class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  
  $days_of_the_week = %w{日 月 火 水 木 金 土}
  
  # beforeフィルター
  
  # paramsハッシュからユーザーを取得。
  def set_user
    if User.where(id: params[:id]).present?
      @user = User.find(params[:id])
    else
      flash[:danger] = "ユーザーが存在しません。"
      redirect_to root_url
    end
  end
  
  # ログイン済みのユーザーか確認。
  def logged_in_user
   store_location
   unless logged_in?
      flash[:danger] = "ログインしてください。"
      redirect_to login_url
    end
  end
  
  # アクセスしたユーザーが現在ログインしているユーザーか確認。
  def correct_user
    redirect_to(root_url) unless current_user?(@user)
  end
  
  # システム管理権限所有かどうか判定。
  def admin_user
    unless current_user.admin?
      flash[:danger] = "権限がありません。"
    redirect_to root_url
  end
  
  # システム管理権限所有者以外は他ユーザーへのアクセス制限
  # アクセスしたユーザーが現在のログインユーザーまたは上長ユーザーかを確認。
  def admin_or_correct_user
    if params[:id] == "1"
      redirect_to root_url
      return
    end
    unless current_user?(@user) || current_user.superior?
      flash[:danger] = "権限がありません。"
      redirect_to root_url
    end
  end
  
  # ページ出力前に1ヶ月分のデータの存在を確認・セット
  def set_one_month
    @first_day = params[:date].nil? ?
    Date.current.beginning_of_month : params[:date].to_date
    @last_day = @first_day.end_of_month
    one_month = [*@first_day..@last_day] # 対象の月の日数を代入
    # ユーザーに紐付く一ヶ月分のレコードを検索し取得。
    # orderにて昇順に並び替え。
    @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
    
    unless one_month.count == @attendances.count # それぞれの件数（日数）が一致するか評価
      ActiveRecord::Base.transaction do # トランザクションを開始
        # 繰り返し処理により、1ヶ月分の勤怠データを生成
        one_month.each {|day| @user.attendances.create!(worked_on: day) }
      end
      @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
    end 
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐
    flash[:danger] = "ページ情報の取得に失敗しました、再アクセスしてください。"
    redirect_to root_url
  end
end