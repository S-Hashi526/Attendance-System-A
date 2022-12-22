class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info, :edit_basic_info_admin, :working_list, :attendance_log, :csv_export]
  # アクセス先のログインユーザーor上長（管理者も不可）
  before_action :admin_or_correct_user, only: :show
  # ログイン中のユーザーか
  before_action :logged_in_user, only: [:edit, :index, :edit, :update, :destroy, :edit_basic_info, :update_basic_info, :edit_basic_info_admin, :attendance_log, :working_list]
  # アクセス先のログインユーザー
  before_action :correct_user, only: [:edit, :update, :attendance_log]
  # 管理者ユーザー
  before_action :admin_user, only: [:index, :destroy, :edit_basic_info, :update_basic_info, :edit_basic_info_admin, :working_list]
  # 1か月分の勤怠情報を取得
  before_action :set_one_month, only: [:show,  :attendance_log, :csv_export]

  def index
    @users = User.paginate(page: params[:page])
    @users = @users.where('name like ?', "%#{params[:search]}%") if params[:search].present?
  end
  
  def show
    @users = User.all
    @worked_sum = @attendances.where.not(started_at: nil).count
    @r_count = Report.where(r_request: @user.name, r_approval: "申請中").count
    @a_count = Attendance.where(c_request: @user.name, c_approval: "申請中").count
    @o_count = Attendance.where(o_request: @user.name, o_approval: "申請中").count
  end

  def csv_export
    respond_to do |format|
      format.html 
        # html用の処理を記述
      format.csv do |csv|
        # csv用の処理を記述
        send_attendances_csv(@attendances)
      end
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = '新規作成に成功しました。'
      redirect_to @user
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @user.update_attributes(user_params)
      flash[:success] = "アカウント情報を更新しました。"
      redirect_to edit_user_url
    else
      flash[:danger] = "#{@user.name}のアカウント情報の更新は失敗しました。"
      render :edit
    end
  end
  
  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end
  
  def edit_basic_info
  end

  def edit_basic_info_admin
  end
  
  def working_list
    @users = User.all
  end

  def update_basic_info
    if @user.update_attributes(basic_info_params)
      flash[:success] = "#{@user.name}の基本情報を更新しました。"
    else
      flash[:danger] = "#{@user.name}の更新は失敗しました。<br><li>" + @user.errors.full_messages.join("</li><li>")
    end
    redirect_to users_url
  end

  def import
    # fileはtmp(temporary)に自動保存
    if params[:file].presence
      @regist_check = User.import(params[:file])

      if @regist_check
        flash[:success] = "CSVファイルのインポートが完了しました。"
      else
        flash[:danger] = "更新可能なデータがありませんでした。"
      end
    else
      flash[:danger] = "CSVファイルを選択してください。"
    end
    redirect_to users_url
  end
  
  # 勤怠修正ログ
  def attendance_log
    @attendances = Attendance.where(user_id: @user).where(c_approval: "承認").order(worked_on: "DESC")

    if params[:attendance].present?
      unless params[:attendance][:worked_on] == ""
        @search_date = params[:attendance][:worked_on] + "-1"
        @attendances = @attendances.where(started_at: @search_date.in_time_zone.all_year)
                                    .where(started_at: @search_date.in_time_zone.all_month)
        if @attendances.count == 0
          flash.now[:warning] = "承認済みの修正履歴がありません。"
        end
      else
        flash.now[:warning] = "年月を選択してください。"
      end
    end
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :affiliation, :employee_number, :uid, :password, :basic_work_time, :designated_work_start_time, :designated_work_end_time)
    end
    
    def basic_info_params
      params.require(:user).permit(:name, :email, :affiliation, :employee_number, :uid, :password, :basic_work_time, :designated_work_start_time, :designated_work_end_time)
    end

    def send_attendances_csv(attendances)
      #文字化け防止
      bom = "\uFEFF"
      # CSV.generate：対象データを自動的にCSV形式に変換してくれるCSVライブラリの一種
      csv_data = CSV.generate(bom, encoding: Encoding::SJIS, row_sep: "\r\n", force_quotes: true) do |csv|
        # %w()は空白で区切って配列を返す。
        column_names = %W(日付 曜日 出勤時間 退勤時間)
        # csv << column_namesは表の列に入る名前を定義
        csv << column_names
        # column_valuesに代入するカラム値を定義
        @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
        @attendances.each do |day|
          column_values = [
            l(day.worked_on, format: :short),
            $days_of_the_week[day.worked_on.wday],
            if day.started_at.present? && (day.c_request == "承認").present?
              l(day.started_at.floor_to(60*15), format: :time)
            else
              ""
            end,
            if day.finished_at.present? && (day.c_request == "承認").present?
              l(day.finished_at.floor_to(60*15), format: :time)
            else
              ""
            end
          ]
        # csv << column_valueは表の行に入る値を定義
          csv << column_values
        end
      end
      # csv出力ファイル名を定義
      send_data(csv_data, filename: "#{user.name}の勤怠一覧.csv")
    end

    def query
      if params[:user].present? && params[:user][:name] != ""
        @search_value = User.where('name LIKE ?', "%#{params[:user][:name]}%")
      else
        User.all
      end
    end
end