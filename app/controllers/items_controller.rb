class ItemsController < ApplicationController
  before_action :set_item, only: %i[show edit update destroy]

  def index
    # 全アイテムを基本クエリとして設定
    @items = current_user.items.order(created_at: :desc)
    # テキスト検索があればそれに基づいてフィルタリング
    if params[:search].present?
      @items = @items.left_joins(:tags).where("items.title LIKE :search OR items.description LIKE :search OR tags.name LIKE :search", search: "%#{params[:search]}%").distinct
    end
    # タグに基づいてさらにフィルタリング
    if params[:tag].present?
      @items = @items.tagged_with(params[:tag])
    end
    # ページネーションは最終的なクエリセットに対して適用
    @items = @items.page(params[:page]).per(10)
  end
  
  def show; end

  def new
    @item = Item.new
  end

  def edit; end

  def create
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
    @item.destroy
    flash[:success] = 'アイテムを削除しました'
    redirect_to items_url
  end

  private

  def item_params
    params.require(:item).permit(:title, :description, :item_url, :tag_list)
  end

  def set_item
    @item = current_user.items.find_by(id: params[:id])
    unless @item
      redirect_to items_path, alert: '指定されたアイテムにはアクセスできません。'
    end
  end

end
