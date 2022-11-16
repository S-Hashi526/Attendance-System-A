class BasesController < ApplicationController
  before_action :set_base, only: [:show, :edit, :update, :destroy]

  # 管理者かどうか
  before_action :admin_user, only: [:index, :show, :new, :edit, :update]

  def new
  end

  def edit
  end

  def index
    @base = Base.all
  end

  def create
    @base = Base.create(base_params)
    if @base.update_attributes(base_params)
      flash[:success] = "#{@base.base_name}の拠点情報が追加されました。"
      redirect_to bases_url
    else
      flash[:danger] = "拠点情報を追加できませんでした。<br><li>" + @base.errors.full_messages.join("</li><li>")
      redirect_to bases_url
    end
  end
  
  def update
    @base_name = @base.base_name
    if @base.update_attributes(base_params)
      flash[:success] = "#{@base.base_name}の拠点情報が更新されました。"
      redirect_to bases_path
    else
      flash[:success] = "#{@base_name}の拠点情報を更新できませんでした。"
      redirect_to bases_path
    end
  end
  
  def destroy
    @basename = @base.base_name
    @base.destroy
    flash[:success] = "#{@basename}の削除が完了しました。"
    redirect_to bases_path
  end

  private

    def set_base
      @base = Base.find(params[:id])
    end

    def base_params
      params.require(:base).permit(:base_no, :base_name, :attendance_type)
    end
end
