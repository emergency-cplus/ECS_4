class ItemsController < ApplicationController
  before_action :require_login
  before_action :check_demo_user_permissions, only: [:edit, :update, :destroy, :new, :create]
  before_action :set_item, only: %i[show edit update destroy]
  
  def index
    # デモユーザーの場合は全ユーザーのアイテムを表示
    # 管理者も全アイテムを閲覧可能
    # 全アイテムを基本クエリとして設定
    @items = if current_user.can_view_all_items?
               Item.order(created_at: :desc)
             else
               current_user.items.order(created_at: :desc)
             end

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
  end

  def edit; end

  def create
    # デモユーザーの二重チェック
    return redirect_to items_path, alert: 'デモユーザーはこの操作を実行できません。' unless current_user.can_modify_items?
    
    @item = current_user.items.new(item_params)
    
    # nil チェックを追加
    tag_list = item_params[:tag_list].presence || ''
    # タグリストを3つまでに制限して処理
    @item.tag_list = item_params[:tag_list].split(',').map(&:strip).uniq.first(3)
    existing_item = Item.find_by(item_url: @item.item_url)
    if existing_item
      redirect_to item_path(existing_item), alert: 'すでにアイテムとして保存されています'
    elsif @item.save
      flash[:success] = 'アイテムを作成しました'
      redirect_to items_url
    else
      flash.now[:danger] = 'アイテムを作成できませんでした'
      render :new, status: :unprocessable_entity
    end
  end

  def update
    # デモユーザーの二重チェック
    return redirect_to items_path, alert: 'デモユーザーはこの操作を実行できません。' unless current_user.can_modify_items?
    
    @item = Item.find(params[:id])
    if @item.update(item_params)
      if item_params[:tag_list].present?
        @item.tag_list = item_params[:tag_list].split(',').map(&:strip).uniq.first(3)
        @item.save
      end
      redirect_to @item, notice: 'Item was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    # デモユーザーの二重チェック
    return redirect_to items_path, alert: 'デモユーザーはこの操作を実行できません。' unless current_user.can_modify_items?
    
    @item.destroy
    flash[:success] = 'アイテムを削除しました'
    redirect_to items_url
  end

  private

  def item_params
    params.require(:item).permit(:title, :description, :item_url, :tag_list)
  end

  def set_item
    # デモユーザーと管理者は全てのアイテムにアクセス可能
    @item = if current_user.can_view_all_items?
              Item.find_by(id: params[:id])
            else
              current_user.items.find_by(id: params[:id])
            end

    unless @item
      redirect_to items_path, alert: '指定されたアイテムにはアクセスできません。'
    end
  end

  def check_demo_user_permissions
    unless current_user.can_modify_items?
      flash[:alert] = 'デモユーザーはこの操作を実行できません。'
      redirect_to items_path
    end
  end
end
