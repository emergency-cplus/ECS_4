class ItemsController < ApplicationController
  before_action :require_login
  before_action :check_demo_user_permissions, only: [:edit, :update, :destroy, :new, :create]
  before_action :set_item, only: %i[show edit update destroy]
  
  def index
    # 基本クエリの設定
    @items = if current_user.admin?
      # 管理者は自分のアイテムのみ閲覧可能
      current_user.items.includes(:tags)
    elsif current_user.demo?
      # デモユーザーは自分のアイテム（通常はない）と管理者の全アイテムを閲覧可能
      user_items = current_user.items.includes(:tags)
      admin_items = Item.includes(:tags).where(user_id: User.where(role: :admin).pluck(:id))
      user_items.or(admin_items)
    else
      # 一般ユーザーは自分のアイテムと管理者の「一般公開」設定されたアイテムを閲覧可能
      user_items = current_user.items.includes(:tags)
      admin_items = Item.includes(:tags)
                        .where(user_id: User.where(role: :admin).pluck(:id), 
                               shared_with_general: true)
      user_items.or(admin_items)
    end.order(created_at: :desc)

    # テキスト検索があればそれに基づいてフィルタリング
    if params[:search].present?
      @items = @items.left_joins(:tags)
                     .where("items.title LIKE :search OR items.description LIKE :search OR tags.name LIKE :search", 
                            search: "%#{params[:search]}%")
                     .distinct
    end

    # タグに基づいてさらにフィルタリング
    if params[:tag].present?
      @items = @items.tagged_with(params[:tag])
    end

    # 新規作成ボタン表示制御用フラグ
    @can_create = current_user.can_modify_items?

    # ページネーションは最終的なクエリセットに対して適用
    @items = @items.page(params[:page]).per(10)
  end
  
  def show; end

  def new
    @item = Item.new
    @is_admin = current_user.admin?
  end

  def edit
    @is_admin = current_user.admin?
    
    # 自分のアイテムでない場合は編集不可
    unless @item.user_id == current_user.id
      redirect_to items_path, alert: '他のユーザーのアイテムは編集できません'
    end
  end

  def create
    @item = current_user.items.new(item_params_with_sharing)
    
    video_id = @item.send(:extract_video_id, @item.item_url)
    existing_item = current_user.items
                               .where.not(id: 0) # 存在しないIDを指定
                               .find_by("item_url LIKE ?", "%/shorts/#{video_id}%")

    if existing_item
      redirect_to item_path(existing_item), alert: 'すでにアイテムとして保存されています'
    elsif @item.save
      flash[:success] = 'アイテムを作成しました'
      redirect_to items_url
    else
      @is_admin = current_user.admin?
      flash.now[:danger] = 'アイテムを作成できませんでした'
      render :new, status: :unprocessable_entity
    end
  end

  def update
    # 自分のアイテムでない場合は更新不可
    unless @item.user_id == current_user.id
      return redirect_to items_path, alert: '他のユーザーのアイテムは更新できません'
    end
    
    # 更新前に重複チェック
    video_id = @item.send(:extract_video_id, item_params_with_sharing[:item_url])
    existing_item = current_user.items
                               .where.not(id: @item.id)
                               .find_by("item_url LIKE ?", "%/shorts/#{video_id}%")

    if existing_item
      flash.now[:alert] = 'すでにこの動画は登録されています'
      @is_admin = current_user.admin?
      render :edit, status: :unprocessable_entity
    elsif @item.update(item_params_with_sharing)
      redirect_to @item, success: 'アイテム更新に成功しました'
    else
      @is_admin = current_user.admin?
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    # デモユーザーの二重チェック
    return redirect_to items_path, alert: 'デモユーザーはこの操作を実行できません。' unless current_user.can_modify_items?

    # 自分のアイテムでない場合は削除不可
    unless @item.user_id == current_user.id
      return redirect_to items_path, alert: '他のユーザーのアイテムは削除できません'
    end

    @item.destroy
    flash[:notice] = 'アイテムを削除しました'
    redirect_to items_url
  end

  private

  def set_item
    @item = if current_user.admin?
              # 管理者は自分のアイテムのみアクセス可能
              current_user.items.find_by(id: params[:id])
            elsif current_user.demo?
              # デモユーザーは自分のアイテムと管理者の全アイテムにアクセス可能
              user_items = current_user.items
              admin_items = Item.where(user_id: User.where(role: :admin).pluck(:id))
              user_items.or(admin_items).find_by(id: params[:id])
            else
              # 一般ユーザーは自分のアイテムと管理者の「一般公開」設定されたアイテムにアクセス可能
              user_items = current_user.items
              admin_items = Item.where(user_id: User.where(role: :admin).pluck(:id), 
                                     shared_with_general: true)
              user_items.or(admin_items).find_by(id: params[:id])
            end

    unless @item
      redirect_to items_path, alert: '指定されたアイテムにはアクセスできません。'
    end
  end

  def item_params
    params.require(:item).permit(:title, :item_url, :description, :tag_list)
  end
  
  # 管理者用のパラメータ（一般公開設定を含む）
  def item_params_with_sharing
    if current_user.admin?
      params.require(:item).permit(:title, :item_url, :description, :tag_list, :shared_with_general)
    else
      item_params
    end
  end

  def check_demo_user_permissions
    unless current_user.can_modify_items?
      flash[:alert] = 'デモユーザーはこの操作を実行できません。'
      redirect_to items_path
    end
  end
end
