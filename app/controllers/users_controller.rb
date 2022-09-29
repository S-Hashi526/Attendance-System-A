class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :logged_in_user, only: [:edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:index, :destroy, :edit_basic_info, :update_basic_info]
  before_action :admin_or_correct_user, only: :show
  before_action :set_one_month, only: :show

  def index
    @users = User.paginate(page: params[:page])
    @users = @users.where('name like ?', "%#{params[:search]}%") if params[:search].present?
  end
  
  def show
    @worked_sum = @attendances.where.not(started_at: nil).count
    #@r_count = Report.where(r_request: @user.name, r_approval: "申請中").count
    #@a_count = Attendance.where(c_request: @user.name, c_approval: "申請中").count
    #@o_count = Attendance.where(o_request: @user.name, o_approval: "申請中").count
  end

  def csv_export
    raspond_to do |format|
      format.html do
          #html用の処理を書く
      end
      format.csv do
          #csv用の処理を書く
        send_data render_to_string,
        filename: "【勤怠】#{@user.name}_#{@first_day.strftim("%Y-%m")}.csv", type: :csv
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
      redirect_to @user
    else
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
  
  def working_list
    @user = User.all
  end

  def update_basic_info
    if @user.update_attributes(basic_info_params)
      flash[:success] = "#{@user.name}の基本情報を更新しました。"
    else
      flash[:danger] = "#{@user.name}の更新は失敗しました。"+ @user.errors.full_messages.join("<br>")
    end
    redirect_to users_url
  end

  def import
    # fileはtmp(temporary）に自動保存
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
  
  private

    def user_params
      params.require(:user).permit(:name, :email, :department, :password, :password_confirmation)
    end
    
    def basic_info_params
      params.require(:user).permit(:department, :basic_time, :work_time)
    end
    
end